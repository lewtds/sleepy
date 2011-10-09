using Gee;

class SleepTimer : GLib.Object
{
        public SleepTimer(DateTime target)
        {
                this.wake_target = target;
                fill_sleep_targets();
        }

        public bool start()
        {
                if (!running && current_target!=null) {
                        running = true;
                        Timeout.add_seconds(MINUTE_LENGTH, timer_loop);
                        started();
                        return true;
                }
                return false;
        }

        public void stop()
        {
                running = false;
                stopped();
        }

        public TimeSpan get_remaining()
        {
                //We should return string but GTimer uses microseconds so I follow suit and put TimeSpan here
                return current_target.difference(new DateTime.now_local());
        }

        public DateTime? get_next_target()
        {
                return sleep_targets[sleep_targets.index_of(current_target)+1];
        }

        public signal void started();
        public signal void stopped();
        public signal void on_every_minute();
        public signal void alarm();

        private bool timer_loop()
        {
                on_every_minute();
                return running;
        }
        private void fill_sleep_targets()
        {
                var now = new DateTime.now_local();
                sleep_targets = new ArrayList<DateTime>();
                var target = wake_target.add_minutes(-TIME_BEFORE_SLEEP);
                while (target.difference(now) >= 60000000*TIME_BEFORE_ALARM) {

                        sleep_targets.insert(0, target);
                        target = target.add_minutes(-CYCLE_LENGTH);
                }
                current_target = sleep_targets[0];
        }

        private ArrayList<DateTime> sleep_targets;
        public DateTime current_target
        {
                get;
                private set;
        }
        public DateTime wake_target
        {
                get;
                private set;
        }
        private bool running
        {
                get;
                private set;
        default = false;
        }
        private const int CYCLE_LENGTH = 90; //90 minutes
        private const int MINUTE_LENGTH = 60; //60 seconds
        private const int TIME_BEFORE_SLEEP = 15; // The average person takes ~14 minutes to get to sleep
        private const int TIME_BEFORE_ALARM = 10;
}
