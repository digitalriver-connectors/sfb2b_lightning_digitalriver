/**
 * @description: Scheduler class to scheduled batch based on specific Interval time
 *               such as ( every15Minutes, every30Minutes, everyHour, every6Hours and every Monday).
 *               It is a facade class that aggregates all schedule instances as a global static properties.
 *               As a result, every schedule can be started with the same API and capabilities using ConnectorScheduler.
 *
 *               When a new scheduled class introduced it must be extended from BaseScheduler and defined as a
 *               static global property on the ConnectorScheduler (see ProductSync example).
 *
 * @example
 *      DRB2B_ConnectorScheduler.ProductSync.withSize(10).scheduleHourly(1);
 */
global class DRB2B_ConnectorScheduler {
    public static final String JOB_NAME_PREFIX_PURGE_LOGS = 'Digital River - Purge Logs';
    public static final String JOB_NAME_PREFIX_PRODUCT_SYNC = 'Digital River - Products Synchronization';
    public static final String JOB_NAME_PREFIX_FULFILLMENT = 'Digital River - Order Fulfillment';
    public static final String JOB_NAME_PREFIX_SKU_GROUP = 'Digital River - SKU Group';

    public static final Integer DEFAULT_CHUNK_SIZE = 200;
    public static final Integer DEFAULT_FULFILLMENT_CHUNK_SIZE = 100;
    public static final Integer DEFAULT_SKU_GROUP_CHUNK_SIZE = 100;

    global static BaseScheduler PurgeLogs {
        get {
            if (PurgeLogs == null) {
                PurgeLogs = new PurgeLogsScheduler();
            }
            return PurgeLogs;
        }
        private set;
    }

    global static BaseScheduler ProductSync {
        get {
            if (ProductSync == null) {
                ProductSync = new ProductSyncScheduler();
            }
            return ProductSync;
        }
        private set;
    }

    global static BaseScheduler OrderFulfillment {
        get {
            if (OrderFulfillment == null) {
                OrderFulfillment = new OrderFulfillmentScheduler();
            }
            return OrderFulfillment;
        }
        private set;
    }
    global static BaseScheduler RetriveSKUGroup {
        get {
            if (RetriveSKUGroup == null) {
                RetriveSKUGroup = new RetriveSKUGroupScheduler();
            }
            return RetriveSKUGroup;
        }
        private set;
    }

    global static BaseScheduler RetrieveSKUGroup {
        get {
            if (RetrieveSKUGroup == null) {
                RetrieveSKUGroup = new RetrieveSKUGroupScheduler();
            }
            return RetrieveSKUGroup;
        }
        private set;
    }

    global class PurgeLogsScheduler extends BaseScheduler {
        global PurgeLogsScheduler() {
            this.batchSchedulable = new BatchSchedulable(new DCM_LogCleanerBatch(), DEFAULT_CHUNK_SIZE);
            this.name = JOB_NAME_PREFIX_PURGE_LOGS;
        }
    }

    global class ProductSyncScheduler extends BaseScheduler {
        global ProductSyncScheduler() {
            this.batchSchedulable = new BatchSchedulable(new DRB2B_ProductsSyncBatch(), DEFAULT_CHUNK_SIZE);
            this.name = JOB_NAME_PREFIX_PRODUCT_SYNC;
        }
    }

    global class OrderFulfillmentScheduler extends BaseScheduler {
        global OrderFulfillmentScheduler() {
            this.batchSchedulable = new BatchSchedulable(
                new DRB2B_OrderFulfillmentBatchJob(),
                DEFAULT_FULFILLMENT_CHUNK_SIZE
            );
            this.name = JOB_NAME_PREFIX_FULFILLMENT;
        }

        // Cannot specify batch size greater than 100 as Execute method cannot run more than 100 callouts
        global override BaseScheduler withSize(Integer size) {
            if (size > DEFAULT_FULFILLMENT_CHUNK_SIZE) {
                this.batchSchedulable.withSize(DEFAULT_FULFILLMENT_CHUNK_SIZE);
            } else {
                this.batchSchedulable.withSize(size);
            }
            return this;
        }
    }

    global class RetriveSKUGroupScheduler extends BaseScheduler {
        global RetriveSKUGroupScheduler() {
            this.batchSchedulable = new BatchSchedulable(
                new DRB2B_RetrieveSkuGroup(),
                DEFAULT_SKU_GROUP_CHUNK_SIZE
            );
            this.name = JOB_NAME_PREFIX_SKU_GROUP;
        }

        // Cannot specify batch size greater than 100 as Execute method cannot run more than 100 callouts
        global override BaseScheduler withSize(Integer size) {
            if (size > DEFAULT_SKU_GROUP_CHUNK_SIZE) {
                this.batchSchedulable.withSize(DEFAULT_SKU_GROUP_CHUNK_SIZE);
            } else {
                this.batchSchedulable.withSize(size);
            }
            return this;
        }
    }

    global class RetrieveSKUGroupScheduler extends BaseScheduler {

        global RetrieveSKUGroupScheduler() {
            this.batchSchedulable = new BatchSchedulable(
                new DRB2B_RetrieveSkuGroup(),
                DEFAULT_SKU_GROUP_CHUNK_SIZE
            );
            this.name = JOB_NAME_PREFIX_SKU_GROUP;
        }

        // Cannot specify batch size greater than 100 as Execute method cannot run more than 100 callouts
        global override BaseScheduler withSize(Integer size) {
            if (size > DEFAULT_SKU_GROUP_CHUNK_SIZE) {
                this.batchSchedulable.withSize(DEFAULT_SKU_GROUP_CHUNK_SIZE);
            } else {
                this.batchSchedulable.withSize(size);
            }
            return this;
        }
    }

    global abstract class BaseScheduler {
        public String name;
        public BatchSchedulable batchSchedulable;

        global virtual BaseScheduler withSize(Integer size) {
            this.batchSchedulable.withSize(size);

            return this;
        }

        /**
         * Schedules a few jobs to run every X minutes in an hour.
         */
        global void scheduleEveryXMinutes(Integer everyMinute) {
            String everyXMinute = ' - Every ' + String.valueOf(everyMinute) + ' Minutes';
            Scheduler sch = new Scheduler();
            sch.scheduleEveryXMinutes(name + everyXMinute, everyMinute, batchSchedulable);
        }

        /**
         * Schedules job to run every hour at specified minutes.
         */
        global void scheduleHourly(Integer minute) {
            String hourly = ' - Hourly at ' + minute + ' Minutes';
            Scheduler sch = new Scheduler();
            sch.scheduleHourly(name + hourly, minute, batchSchedulable);
        }

        /**
         * Schedules job to run every day at specified time.
         */
        global void scheduleDaily(Integer hour, Integer minute) {
            String daily = ' - Daily at ' + hour + ':' + minute;
            Scheduler sch = new Scheduler();
            sch.scheduleDaily(name + daily, hour, minute, batchSchedulable);
        }

        /**
         * Schedules job to run every day on specified day of the week.
         * @param dayOfWeek 1-7 or one of the following: [SUN, MON, TUE, WED, THU, FRI, SAT]
         */
        global void scheduleWeekly(String dayOfWeek) {
            String weekly = ' - Weekly';
            Scheduler sch = new Scheduler();
            sch.scheduleWeekly(name + weekly, dayOfWeek, batchSchedulable);
        }

        /**
         * Schedules job to run every month on specified day of the month.
         *
         * @param dayOfMonth Possible values:<br/>
         * 1-31 Runs on specific day of month<br/>
         * 1,10,15 Runs on 1st, 10th and 15th day of month <br/>
         * 1-15  Runs from 1st to 15th day of month<br/>
         * 1/5 Runs on every 5th day of month, starting on the first of the month   <br/>
         * L Runs on last day of month <br/>
         * 20W Runs on nearest weekday of the given day<br/>
         *
         */
        global void scheduleMonthly(String dayOfMonth) {
            String monthly = ' - Monthly';
            Scheduler sch = new Scheduler();
            sch.scheduleMonthly(name + monthly, dayOfMonth, batchSchedulable);
        }

        /**
         * Schedule a Job by specifying a Cron Expression. This is useful when you try to specify a job to run every 4 hours
         */
        global void scheduleCronExpr(String jobName, String cronExpr) {
            Scheduler sch = new Scheduler();
            sch.scheduleCronExpr(String.isNotBlank(jobName) ? jobName : name, cronExpr, batchSchedulable);
        }

        /**
         * Schedules job to run
         */
        global void schedule(
            String seconds,
            String minutes,
            String hour,
            String dayOfMonth,
            String month,
            String dayOfWeek,
            String optionalYear
        ) {
            String schedule = ' - Schedule';
            Scheduler sch = new Scheduler();
            sch.schedule(
                name + schedule,
                seconds,
                minutes,
                hour,
                dayOfMonth,
                month,
                dayOfWeek,
                optionalYear,
                batchSchedulable
            );
        }
    }
}