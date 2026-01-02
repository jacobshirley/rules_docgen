/**
 * Represents the priority level of a task.
 *
 * Priority indicates the relative importance of a task and helps determine the order
 * in which tasks should be worked on. Higher priority tasks should generally be completed
 * before lower priority tasks.
 *
 * Priority levels are ordered from lowest to highest:
 *
 * 1. {@link TaskPriority.LOW} - Can be done when time permits
 * 2. {@link TaskPriority.MEDIUM} - Normal priority, should be completed in due course
 * 3. {@link TaskPriority.HIGH} - Important, should be prioritized
 * 4. {@link TaskPriority.URGENT} - Critical, requires immediate attention
 *
 * @remarks
 * Priority Guidelines:
 * - **LOW**: Nice-to-have features, minor improvements, or tasks that can wait until
 *   other work is complete.
 * - **MEDIUM**: Standard tasks that should be completed as part of normal workflow.
 *   This is the default priority for most tasks.
 * - **HIGH**: Important tasks that impact key functionality or user experience.
 *   Should be prioritized over medium and low priority tasks.
 * - **URGENT**: Critical issues that require immediate attention, such as production
 *   bugs, security vulnerabilities, or blocking issues.
 *
 * @example
 * ```typescript
 * const priority = TaskPriority.HIGH;
 * console.log(priority); // "high"
 * console.log(priority === TaskPriority.URGENT); // false
 * ```
 *
 * @public
 */
export enum TaskPriority {
    /**
     * Low priority - can be done when time permits.
     *
     * Tasks with this priority are not time-sensitive and can be completed
     * when there are no higher priority tasks remaining.
     */
    LOW = "low",

    /**
     * Medium priority - normal priority, should be completed in due course.
     *
     * This is the default priority for most tasks. Tasks with this priority
     * should be completed as part of the normal workflow.
     */
    MEDIUM = "medium",

    /**
     * High priority - important, should be prioritized.
     *
     * Tasks with this priority are important and should be completed before
     * medium and low priority tasks.
     */
    HIGH = "high",

    /**
     * Urgent priority - critical, requires immediate attention.
     *
     * Tasks with this priority are critical and require immediate attention.
     * These should be worked on before all other tasks.
     */
    URGENT = "urgent",
}

