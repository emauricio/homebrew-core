class Minimodem < Formula
  desc "General-purpose software audio FSK modem"
  homepage "http://www.whence.com/minimodem/"
  url "http://www.whence.com/minimodem/minimodem-0.22.1.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/m/minimodem/minimodem_0.22.1.orig.tar.gz"
  sha256 "f41dd27367ffe1607c6b631bb7ab6e1c5c099490e295ce1b603cc54416845ce9"

  bottle do
    cellar :any
    sha256 "dff8b43ec99ba9b0cf93cdda0d08e38116e9748267fb8e47243b2a72528bb21e" => :yosemite
    sha256 "119eaeabfeceebb0e429413deb6e77a7e5e50916a8ddb0f7de6fef4cc1ce2e0d" => :mavericks
    sha256 "8d136f2e977ffa388ee4bd9a983c75bceb2c829e1b7e288f9f2f22e170d46f59" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "libsndfile"
  depends_on "fftw"
  depends_on "pulseaudio"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--without-alsa"
    system "make", "install"
  end

  test do
    system "#{bin}/minimodem", "--benchmarks"
  end
end
