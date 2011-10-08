using Gtk;
using Notify;


void main(string[] args)
{
        Gtk.init(ref args);
        Notify.init(Config.APPLONGNAME);

        var indicator = new TimerControl();
        Gtk.main();
        Notify.uninit();
}
