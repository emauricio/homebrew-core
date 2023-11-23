require "language/perl"

class Sslmate < Formula
  include Language::Perl::Shebang
  include Language::Python::Virtualenv

  desc "Buy SSL certs from the command-line"
  homepage "https://sslmate.com"
  url "https://packages.sslmate.com/other/sslmate-1.9.1.tar.gz"
  sha256 "179b331a7d5c6f0ed1de51cca1c33b6acd514bfb9a06a282b2f3b103ead70ce7"
  license "MIT"
  revision 1

  livecheck do
    url "https://packages.sslmate.com/other/"
    regex(/href=.*?sslmate[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "17ae6bb3ed5c430fdda554b990d5a1d5b539b89065ed5944288851b862f83c20"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "d082114fb209257176956b1aebdad10478fc597de6604a5d9999e1c432e8e793"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "d082114fb209257176956b1aebdad10478fc597de6604a5d9999e1c432e8e793"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "d082114fb209257176956b1aebdad10478fc597de6604a5d9999e1c432e8e793"
    sha256 cellar: :any_skip_relocation, sonoma:         "a27cad29a05af1a278ce5472e7a93400ec29f3232d8336042c01db999b495f79"
    sha256 cellar: :any_skip_relocation, ventura:        "ffcccf2b3dfba7bb454eec781fdda76a8e15ee958d3631c5cf5e2c0401bf30c2"
    sha256 cellar: :any_skip_relocation, monterey:       "ffcccf2b3dfba7bb454eec781fdda76a8e15ee958d3631c5cf5e2c0401bf30c2"
    sha256 cellar: :any_skip_relocation, big_sur:        "ffcccf2b3dfba7bb454eec781fdda76a8e15ee958d3631c5cf5e2c0401bf30c2"
    sha256 cellar: :any_skip_relocation, catalina:       "ffcccf2b3dfba7bb454eec781fdda76a8e15ee958d3631c5cf5e2c0401bf30c2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c8cf9d5a489518810246c59334f5f0b2855888075b421698746f08391d965eb7"
  end

  depends_on "python@3.12"

  uses_from_macos "perl"

  on_linux do
    resource "URI::Escape" do
      url "https://cpan.metacpan.org/authors/id/O/OA/OALDERS/URI-5.21.tar.gz"
      sha256 "96265860cd61bde16e8415dcfbf108056de162caa0ac37f81eb695c9d2e0ab77"
    end

    resource "Term::ReadKey" do
      url "https://cpan.metacpan.org/authors/id/J/JS/JSTOWE/TermReadKey-2.38.tar.gz"
      sha256 "5a645878dc570ac33661581fbb090ff24ebce17d43ea53fd22e105a856a47290"
    end
  end

  resource "boto3" do
    url "https://files.pythonhosted.org/packages/d7/1e/919989cd5ffc34ac7bc1107cca3eb1a9e03bbe05232c5ae61f923ecb689e/boto3-1.29.6.tar.gz"
    sha256 "d1d0d979a70bf9b0b13ae3b017f8523708ad953f62d16f39a602d67ee9b25554"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec/"vendor/lib/perl5"

    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install resource("boto3")

    resources.each do |r|
      next if r.name == "boto3"

      r.stage do
        system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}/vendor"
        system "make"
        system "make", "install"
      end
    end

    system "make", "PREFIX=#{prefix}"
    system "make", "install", "PREFIX=#{prefix}"

    env = { PERL5LIB: ENV["PERL5LIB"] }
    env[:PYTHONPATH] = ENV["PYTHONPATH"]
    bin.env_script_all_files(libexec/"bin", env)

    rewrite_shebang detected_perl_shebang, libexec/"bin/sslmate"
  end

  test do
    system "#{bin}/sslmate", "req", "www.example.com"
    # Make sure well-formed files were generated:
    system "openssl", "rsa", "-in", "www.example.com.key", "-noout"
    system "openssl", "req", "-in", "www.example.com.csr", "-noout"
    # The version command tests the HTTP client:
    system "#{bin}/sslmate", "version"
  end
end
