class Ser2net < Formula
  desc "Allow network connections to serial ports"
  homepage "https://ser2net.sourceforge.io"
  url "https://downloads.sourceforge.net/project/ser2net/ser2net/ser2net-4.2.3.tar.gz"
  sha256 "d63448d10064419f1783fbb04d0a95461d54d6b17cf50c9d33a63cbf0c732f37"
  license "GPL-2.0-only"

  livecheck do
    url :stable
    regex(%r{url=.*?/ser2net[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "61d93dbd74a72555d27f9f24e567f5c8a586e63ff348f429573d9f1246f02c63"
    sha256 cellar: :any,                 big_sur:       "daff205c7e62f7a0ad6ce064b5005f80f4e8362b17a2cb3ad87676174d683ba7"
    sha256 cellar: :any,                 catalina:      "3477841d573b2612fff98a0dd1fa8ac46e3d43fdc110ddfd3767f6b433b344a4"
    sha256 cellar: :any,                 mojave:        "822c56bfd75eccbdcc8a447236c996ca146e5efe324eea471dbbc212611dc0be"
    sha256 cellar: :any,                 high_sierra:   "b11cef34c33d9f40ac677c034ff1557444d69735f3d5c88e8eaaffd135237d7d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "55cdacd7322af3a66bbd3f80d9bd3358b51e54c9e839a2b4423e0ef430a31df0"
  end

  depends_on "libyaml"

  resource "gensio" do
    url "https://downloads.sourceforge.net/project/ser2net/ser2net/gensio-2.1.4.tar.gz"
    sha256 "1f5a29aabfb35886893cfda5cd78192db67e96de796dbf9758dbecd4077a3fd8"
  end

  def install
    resource("gensio").stage do
      system "./configure", "--with-python=no",
                            "--disable-dependency-tracking",
                            "--prefix=#{libexec}/gensio"
      system "make", "install"
    end

    ENV.append_path "PKG_CONFIG_PATH", "#{libexec}/gensio/lib/pkgconfig"
    ENV.append_path "CFLAGS", "-I#{libexec}/gensio/include"
    ENV.append_path "LDFLAGS", "-L#{libexec}/gensio/lib"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"

    system "make", "install"

    (etc/"ser2net").install "ser2net.yaml"
  end

  def caveats
    <<~EOS
      To configure ser2net, edit the example configuration in #{etc}/ser2net/ser2net.yaml
    EOS
  end

  service do
    run [opt_sbin/"ser2net", "-p", "12345"]
    keep_alive true
    working_dir HOMEBREW_PREFIX
  end

  test do
    assert_match version.to_s, shell_output("#{sbin}/ser2net -v")
  end
end
