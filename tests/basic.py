machine.wait_for_unit("default.target")
machine.send_key("ctrl-alt-delete")
machine.wait_for_shutdown()
