pragma Singleton

import Quickshell

// The bar button and the notification server live in different windows -- and
// the server is instantiated once per screen -- so the switch has to be a
// singleton rather than a property either side owns.
Singleton {
  property bool active: false

  function toggle() {
    active = !active;
  }
}
