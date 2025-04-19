# This is the configuration file for your Nix environment
# See https://idx.dev/docs/config/nix for more details
{ pkgs, ... }: {

  # List the packages you want to install
  # Available packages: https://search.nixos.org/packages
  packages = [
    # Example: Add git
    pkgs.git

    # Example: Add Node.js (specify the version)
    # pkgs.nodejs_20

    # Example: Add Flutter (defaults to stable channel)
    pkgs.flutter
    (pkgs.flutter.override {
      # This is the line you need to change
      channel = "stable"; # Change this from "beta"
    })

    # Add other packages your project needs here
  ];

  # Set environment variables
  # env = {
  #   MY_VARIABLE = "my-value";
  # };

  # IDX-specific settings
  idx = {
    # Enable previews and specify ports if needed
    # previews = {
    #   enable = true;
    #   previews = [
    #     {
    #       # Example for a web server on port 3000
    #       port = 3000;
    #       label = "Web";
    #     }
    #   ];
    # };

    # Automatically start processes when the workspace opens
    # processes = {
    #   # Example: Start a development server
    #   # dev-server = {
    #   #   command = ["npm", "run", "dev"];
    #   # };
    # };

    # VS Code extensions to install
    # extensions = [
    #   # Example: Add the Dart extension
    #   "dart-code.dart-code"
    #   # Example: Add the Flutter extension
    #   "dart-code.flutter"
    # ];
  };
}
