def assert_owned_by(dir, user):
    actual = machine.succeed(f"stat --format=%U {dir}").strip()
    assert actual == user, f"{dir} is not owned by {user}"

for dir in ["CONFIG", "CACHE", "DATA", "STATE"]:
    assert_owned_by(f"$XDG_{dir}_HOME/..", "root")
    assert_owned_by(f"$XDG_{dir}_HOME", "root")

assert_owned_by("$XDG_CACHE_HOME/nix", "user")
assert_owned_by("$XDG_DATA_HOME/nix", "user")
assert_owned_by("$XDG_STATE_HOME/nixos", "root")
