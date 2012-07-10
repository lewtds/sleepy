using Config;
using Gtk;
using Notify;


void main(string[] args)
{
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.bindtextdomain(GETTEXT_PACKAGE, "/usr/local/share/locale");
        Intl.textdomain(GETTEXT_PACKAGE);
        Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");

        Gtk.init(ref args);
        Notify.init(Config.APPLONGNAME);

        var timer_control = new TimerControl();
        Gtk.main();
        Notify.uninit();
}
