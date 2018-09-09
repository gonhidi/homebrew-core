class Atk < Formula
  desc "GNOME accessibility toolkit"
  homepage "https://library.gnome.org/devel/atk/"
  url "https://download.gnome.org/sources/atk/2.30/atk-2.30.0.tar.xz"
  sha256 "dd4d90d4217f2a0c1fee708a555596c2c19d26fef0952e1ead1938ab632c027b"

  bottle do
    sha256 "c891f2e04a6bb4c77f9f45b673494da1762f51dbc9b567bfad411fd5f27fb302" => :mojave
    sha256 "2fa9dc887ac9710977281e59a7ae22a571596b234ac738479ee26afedbdaba34" => :high_sierra
    sha256 "960f53ddcbd54d708f7fb70ea655a8f14a8f315e20121d157e7927354dae4068" => :sierra
    sha256 "2a03378b3903fbca6caca6811a3e3658fd75914a62dc5dda3a801dd4e16d7a0a" => :el_capitan
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson-internal" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"

  patch :DATA

  def install
    ENV.refurbish_args

    mkdir "build" do
      system "meson", "--prefix=#{prefix}", ".."
      system "ninja"
      system "ninja", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <atk/atk.h>

      int main(int argc, char *argv[]) {
        const gchar *version = atk_get_version();
        return 0;
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    flags = %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/atk-1.0
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -latk-1.0
      -lglib-2.0
      -lgobject-2.0
      -lintl
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end

__END__
diff --git a/meson.build b/meson.build
index 59abf5e..7af4f12 100644
--- a/meson.build
+++ b/meson.build
@@ -73,11 +73,6 @@ if host_machine.system() == 'linux'
   common_ldflags += cc.get_supported_link_arguments(test_ldflags)
 endif

-# Maintain compatibility with autotools on macOS
-if host_machine.system() == 'darwin'
-  common_ldflags += [ '-compatibility_version 1', '-current_version 1.0', ]
-endif
-
 # Functions
 checked_funcs = [
   'bind_textdomain_codeset',
