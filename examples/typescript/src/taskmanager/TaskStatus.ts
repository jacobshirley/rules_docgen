/**
 * Represents the current status of a task.
 *
 * Task status indicates the current state of work on a task. Tasks progress through
 * different statuses as work is completed. The typical flow is:
 *
 * 1. {@link TaskStatus.PENDING} - Task is created but work hasn't started
 * 2. {@link TaskStatus.IN_PROGRESS} - Work on the task is underway
 * 3. {@link TaskStatus.COMPLETED} - Task is finished
 *
 * Tasks can also be {@link TaskStatus.CANCELLED} at any point if they are no longer needed.
 *
 * @remarks
 * The following status transitions are valid:
 * - Any status → {@link TaskStatus.CANCELLED}
 * - {@link TaskStatus.PENDING} → {@link TaskStatus.IN_PROGRESS}
 * - {@link TaskStatus.IN_PROGRESS} → {@link TaskStatus.COMPLETED}
 * - {@link TaskStatus.IN_PROGRESS} → {@link TaskStatus.PENDING} (if work is paused)
 *
 * @example
 * ```typescript
 * const status = TaskStatus.PENDING;
 * console.log(status); // "pending"
 * console.log(status === TaskStatus.IN_PROGRESS); // false
 * ```
 *
 * @public
 */
export enum TaskStatus {
    /**
     * Task has been created but work has not started.
     *
     * This is the default status for newly created tasks. Tasks in this status
     * are waiting to be picked up and started.
     */
    PENDING = "pending",

    /**
     * Work on the task is currently underway.
     *
     * Tasks in this status are actively being worked on. This status indicates
     * that someone has started working on the task and progress is being made.
     */
    IN_PROGRESS = "in-progress",

    /**
     * Task has been finished.
     *
     * Tasks in this status have been completed successfully. Completed tasks
     * are typically archived and no longer appear in active task lists.
     */
    COMPLETED = "completed",

    /**
     * Task has been cancelled and will not be completed.
     *
     * Tasks can be cancelled at any point if they are no longer needed or relevant.
     * Cancelled tasks are not considered for completion and are typically excluded
     * from active work queues.
     */
    CANCELLED = "cancelled",
}

