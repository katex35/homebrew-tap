class Lectern < Formula
  desc "Records lectures on a Mac and turns them into notes, questions and dates"
  homepage "https://github.com/katex35/lectern"
  url "https://github.com/katex35/lectern/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "e12b9641927d06001c7738466cbb5cc46480c4540c749e8ad440ec62c8378176"
  license "MIT"
  head "https://github.com/katex35/lectern.git", branch: "main"

  depends_on macos: :sonoma
  uses_from_macos "swift" => :build

  def install
    # Homebrew picks the SDK of the running macOS, which can be older than the Swift compiler's own;
    # the Observation macros of a newer compiler then do not match it. Swift finds its own SDK instead.
    ENV.delete "SDKROOT"
    # SwiftPM's own sandbox cannot start inside Homebrew's
    ENV["LECTERN_SWIFT_FLAGS"] = "--disable-sandbox"
    system "scripts/bundle.sh"
    prefix.install "build/Lectern.app"
    (bin/"lectern").write <<~SH
      #!/bin/sh
      exec open "#{opt_prefix}/Lectern.app" "$@"
    SH
  end

  def caveats
    <<~EOS
      Open Lectern with:
        lectern

      To find it in Applications and Spotlight too:
        ln -sf #{opt_prefix}/Lectern.app ~/Applications/Lectern.app
    EOS
  end

  test do
    app = prefix/"Lectern.app"
    assert_path_exists app/"Contents/MacOS/lectern-recorder"
    assert_path_exists app/"Contents/Resources/tr.lproj/Localizable.strings"
    system "codesign", "--verify", "--deep", "--strict", app
  end
end
