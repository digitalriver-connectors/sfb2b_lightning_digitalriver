/**
 * @description: Batchable class that has base logic for all batches.
 *               Every batch job of the project must extend this class to be consistent
 *               with the overall architecture of the framework.
 *
 **/
public abstract class DRB2B_BaseBatch implements Database.Batchable<Object> {

    public virtual Iterable<Object> start(Database.BatchableContext context) {
        return onStart(context);
    }

    public virtual void execute(Database.BatchableContext context, List<Object> records) {
        onExecute(context, records);
    }

    public virtual void finish(Database.BatchableContext context) {
        onFinish(context);
    }

    public abstract Iterable<Object> onStart(Database.BatchableContext context);

    public abstract void onExecute(Database.BatchableContext context, List<Object> records);

    public abstract void onFinish(Database.BatchableContext context);
}