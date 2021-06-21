# In case we want to freeze the package version we could use a particular channel snapshot.
{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [
    docker
    etcd
    nats-server
    nodejs-16_x
    pre-commit
  ];

  shellHook = ''
    echo "Run following commands to install pre-commit hooks:"
    echo "pre-commit install"
    echo "pre-commit install --hook commit-msg"
  '';
}
