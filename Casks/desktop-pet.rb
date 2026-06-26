cask "desktop-pet" do
  version "0.16.0"
  sha256 "932ac9c2d88dee4991949ca86c6b837eabf3d6952c2b0ac112c887e4565e7b2e"

  url "https://github.com/acabelloj/desktop-pet-releases/releases/download/v#{version}/DesktopPet"
  name "Desktop Pet"
  desc "Pixel-art desktop companion that lives on your screen"
  homepage "https://github.com/acabelloj/desktop-pet-releases"

  depends_on macos: :ventura # macOS 13+
  depends_on arch: :arm64 # Apple Silicon only

  binary "DesktopPet"

  # The release ships a bare, ad-hoc-signed Mach-O (no Apple Developer ID) plus a
  # SHA256 and an Ed25519 SSH signature. postflight mirrors the project's install.sh:
  #   1. make the staged binary executable
  #   2. clear quarantine so Gatekeeper does not block launch
  #   3. stage the .sig next to the bin/ symlink so the app's verified badge and
  #      in-app updater keep working (the app reads CommandLine.arguments[0] + ".sig").
  #      It is optional — a missing .sig only disables those, the app still launches.
  #   4. register a LaunchAgent so the pet runs now and at every login, pointing at
  #      the stable HOMEBREW_PREFIX/bin/DesktopPet symlink so it survives upgrades.
  postflight do
    require "net/http"

    binary_link = "#{HOMEBREW_PREFIX}/bin/DesktopPet"

    set_permissions staged_path/"DesktopPet", "0755"

    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", staged_path/"DesktopPet"],
                   sudo: false

    sig_url = "https://github.com/acabelloj/desktop-pet-releases/releases/download/v#{version}/DesktopPet.sig"
    begin
      response = Net::HTTP.get_response(URI(sig_url))
      response = Net::HTTP.get_response(URI(response["location"])) if response.is_a?(Net::HTTPRedirection)
      File.write("#{binary_link}.sig", response.body) if response.is_a?(Net::HTTPSuccess)
    rescue => e
      opoo "Could not fetch DesktopPet.sig (#{e.message}); the verified badge and in-app updater will be disabled."
    end

    plist = "#{Dir.home}/Library/LaunchAgents/com.acabelloj.desktop-pet.plist"
    File.write(plist, <<~XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>com.acabelloj.desktop-pet</string>
          <key>ProgramArguments</key>
          <array>
              <string>#{binary_link}</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <true/>
          <key>StandardOutPath</key>
          <string>/tmp/desktop-pet.log</string>
          <key>StandardErrorPath</key>
          <string>/tmp/desktop-pet.err</string>
      </dict>
      </plist>
    XML

    # Best-effort stop of any existing instance. On a fresh install nothing is
    # loaded yet, so bootout exits 3 ("No such process") — that is expected and
    # must not abort the install, hence must_succeed: false.
    system_command "/bin/launchctl",
                   args:         ["bootout", "gui/#{Process.uid}/com.acabelloj.desktop-pet"],
                   sudo:         false,
                   print_stderr: false,
                   must_succeed: false
    system_command "/bin/launchctl",
                   args: ["bootstrap", "gui/#{Process.uid}", plist],
                   sudo: false
  end

  uninstall launchctl: "com.acabelloj.desktop-pet",
            quit:      "com.acabelloj.desktop-pet",
            delete:    "~/Library/LaunchAgents/com.acabelloj.desktop-pet.plist"

  zap trash: [
    "~/.desktop-pet",
    "~/Library/LaunchAgents/com.acabelloj.desktop-pet.plist",
  ]

  caveats <<~EOS
    Desktop Pet runs as a background menu-bar app and was registered to launch at
    login. Look for the menu-bar icon to control it.

    It needs Accessibility and Screen Recording permissions for full functionality.
    See: #{homepage}
  EOS
end
