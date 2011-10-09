using Gtk;
using Notify;
using Config;

void main(string[] args)
{
        Intl.setlocale(LocaleCategory.ALL, "");
        Intl.bindtextdomain(GETTEXT_PACKAGE, LOCALE_DIR);
        Intl.textdomain(GETTEXT_PACKAGE);
        Intl.bind_textdomain_codeset(GETTEXT_PACKAGE, "UTF-8");

        Gtk.init(ref args);
        Notify.init(Config.APPLONGNAME);

        var timer_control = new TimerControl();
        Gtk.main();
        Notify.uninit();
}
