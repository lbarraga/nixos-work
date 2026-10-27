pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Everything the system panel shows, read straight from /proc on a one second
// tick. Cheap enough to run always -- three small reads and a parse -- so the
// graphs have history by the time the panel is opened. Only `df` waits for the
// panel, since that one forks.
Singleton {
  id: root

  readonly property int historyLength: 60

  // all loads are 0..1, all sizes are bytes
  property real cpu: 0
  property var cores: []
  property var cpuHistory: []

  property real memUsed: 0
  property real memTotal: 0
  property var memHistory: []

  property real rxRate: 0
  property real txRate: 0

  property real diskUsed: 0
  property real diskTotal: 0

  // how many panels are open; df runs only while that is non-zero
  property int watchers: 0

  // previous counters, to turn /proc's monotonic totals into rates
  property var lastCpu: null
  property var lastNet: null
  property real lastNetAt: 0

  function watch() {
    root.watchers += 1;
    if (root.watchers === 1)
      disk.running = true;
  }

  function unwatch() {
    root.watchers = Math.max(0, root.watchers - 1);
  }

  // The squarest grid for n cores that is still a complete rectangle: the
  // divisor pair closest to sqrt(n). A full 7x1 beats a 3x3 with two holes in
  // it, so square loses to filled when the core count has no better factors.
  function gridColumns(n) {
    if (n <= 0)
      return 1;
    for (let d = Math.floor(Math.sqrt(n)); d >= 1; d--)
      if (n % d === 0)
        return n / d;
    return n;
  }

  function formatSize(bytes) {
    if (!(bytes > 0))
      return "0";
    const units = ["B", "K", "M", "G", "T"];
    let v = bytes;
    let u = 0;
    while (v >= 1024 && u < units.length - 1) {
      v /= 1024;
      u++;
    }
    // one decimal below ten, so "1.4G" but "64G"
    return (v < 10 && u > 0 ? v.toFixed(1) : Math.round(v)) + units[u];
  }

  function formatRate(bytesPerSecond) {
    if (!(bytesPerSecond > 0))
      return "0 B/s";
    const units = ["B/s", "K/s", "M/s", "G/s"];
    let v = bytesPerSecond;
    let u = 0;
    while (v >= 1024 && u < units.length - 1) {
      v /= 1024;
      u++;
    }
    return (v < 10 && u > 0 ? v.toFixed(1) : Math.round(v)) + " " + units[u];
  }

  function push(history, value) {
    return history.concat([value]).slice(-root.historyLength);
  }

  FileView {
    id: statFile
    path: "/proc/stat"
    blockLoading: true

    onLoaded: {
      // Each cpu line is `cpu<n> user nice system idle iowait ...`, counters
      // since boot. Load is the share of the interval that was not idle.
      const totals = [];
      const idles = [];

      for (const line of text().split("\n")) {
        if (!line.startsWith("cpu"))
          break;
        const f = line.split(/\s+/);
        const nums = f.slice(1).map(Number);
        if (nums.length < 5)
          continue;
        totals.push(nums.reduce((a, b) => a + b, 0));
        idles.push(nums[3] + nums[4]);
      }

      const prev = root.lastCpu;
      root.lastCpu = {
        totals: totals,
        idles: idles
      };
      if (!prev || prev.totals.length !== totals.length)
        return;

      const load = [];
      for (let i = 0; i < totals.length; i++) {
        const dt = totals[i] - prev.totals[i];
        const di = idles[i] - prev.idles[i];
        load.push(dt > 0 ? Math.max(0, Math.min(1, 1 - di / dt)) : 0);
      }

      // index 0 is the aggregate line, the rest are the cores
      root.cpu = load[0];
      root.cores = load.slice(1);
      root.cpuHistory = root.push(root.cpuHistory, root.cpu);
    }
  }

  FileView {
    id: memFile
    path: "/proc/meminfo"
    blockLoading: true

    onLoaded: {
      // MemAvailable rather than MemFree: free counts cache as used, which on
      // a machine that has been up a while reads as permanently full.
      let total = 0;
      let available = 0;

      for (const line of text().split("\n")) {
        if (line.startsWith("MemTotal:"))
          total = Number(line.split(/\s+/)[1]) * 1024;
        else if (line.startsWith("MemAvailable:"))
          available = Number(line.split(/\s+/)[1]) * 1024;
      }

      if (total <= 0)
        return;
      root.memTotal = total;
      root.memUsed = Math.max(0, total - available);
      root.memHistory = root.push(root.memHistory, root.memUsed / total);
    }
  }

  FileView {
    id: netFile
    path: "/proc/net/dev"
    blockLoading: true

    onLoaded: {
      // Physical interfaces only. A tunnel such as netbird's wt0 carries the
      // same bytes as the link underneath it, so counting both doubles them.
      let rx = 0;
      let tx = 0;

      for (const line of text().split("\n")) {
        const parts = line.split(":");
        if (parts.length < 2)
          continue;
        const name = parts[0].trim();
        if (!/^(en|wl|ww|eth|wlan)/.test(name))
          continue;
        const f = parts[1].trim().split(/\s+/).map(Number);
        rx += f[0];
        tx += f[8];
      }

      const now = Date.now();
      const prev = root.lastNet;
      const elapsed = (now - root.lastNetAt) / 1000;
      root.lastNet = {
        rx: rx,
        tx: tx
      };
      root.lastNetAt = now;

      if (!prev || elapsed <= 0)
        return;
      root.rxRate = Math.max(0, (rx - prev.rx) / elapsed);
      root.txRate = Math.max(0, (tx - prev.tx) / elapsed);
    }
  }

  // No statvfs on the QML side, so this is the one thing that forks.
  Process {
    id: disk
    command: ["df", "-B1", "--output=used,size", "/"]
    stdout: StdioCollector {
      id: diskOut
    }
    onExited: {
      const line = diskOut.text.trim().split("\n")[1];
      if (!line)
        return;
      const f = line.trim().split(/\s+/).map(Number);
      if (f.length < 2 || !(f[1] > 0))
        return;
      root.diskUsed = f[0];
      root.diskTotal = f[1];
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      statFile.reload();
      memFile.reload();
      netFile.reload();
    }
  }

  Timer {
    interval: 15000
    running: root.watchers > 0
    repeat: true
    onTriggered: disk.running = true
  }
}
