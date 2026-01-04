import { TaskPriority } from './TaskPriority'
import { TaskStatus } from './TaskStatus'

/**
 * Represents a task in the task management system.
 *
 * A task is a single work item that needs to be completed. Tasks can be assigned to users,
 * associated with projects, and tracked through various statuses and priorities. Each task has
 * a unique identifier, title, description, and optional metadata such as due date, assigned user,
 * and project association.
 *
 * Tasks are immutable once created. To modify a task, create a new instance with updated values
 * or use the service's update methods.
 *
 * @example
 * ```typescript
 * const task = new Task({
 *   title: "Implement user authentication",
 *   description: "Add JWT-based authentication to the API",
 *   status: TaskStatus.IN_PROGRESS,
 *   priority: TaskPriority.HIGH,
 *   assignedTo: userId,
 *   projectId: projectId,
 *   dueDate: new Date("2024-12-31T23:59:59Z")
 * });
 * ```
 *
 * @public
 */
export class Task {
    /**
     * Unique identifier for the task.
     */
    public readonly id: string

    /**
     * A brief, descriptive title for the task (1-200 characters).
     */
    public readonly title: string

    /**
     * Detailed description of what needs to be done (up to 5000 characters).
     */
    public readonly description: string

    /**
     * The current status of the task.
     */
    public readonly status: TaskStatus

    /**
     * The priority level of the task.
     */
    public readonly priority: TaskPriority

    /**
     * The ID of the user assigned to this task, or undefined if unassigned.
     */
    public readonly assignedTo?: string

    /**
     * The ID of the project this task belongs to, or undefined if not associated with a project.
     */
    public readonly projectId?: string

    /**
     * Target completion date and time for the task, or undefined if no due date is set.
     */
    public readonly dueDate?: Date

    /**
     * Timestamp when the task was created.
     */
    public readonly createdAt: Date

    /**
     * Timestamp when the task was last updated.
     */
    public readonly updatedAt: Date

    /**
     * Creates a new task with the specified parameters.
     *
     * @param options - Task configuration options
     * @param options.id - Unique identifier for the task. If not provided, a new UUID will be generated.
     * @param options.title - A brief, descriptive title for the task (1-200 characters, required).
     * @param options.description - Detailed description of what needs to be done (up to 5000 characters, required).
     * @param options.status - The current status of the task. Defaults to {@link TaskStatus.PENDING}.
     * @param options.priority - The priority level of the task. Defaults to {@link TaskPriority.MEDIUM}.
     * @param options.assignedTo - The ID of the user assigned to this task, or undefined if unassigned.
     * @param options.projectId - The ID of the project this task belongs to, or undefined if not associated.
     * @param options.dueDate - Target completion date and time for the task, or undefined if no due date is set.
     * @param options.createdAt - Timestamp when the task was created. Defaults to the current time.
     * @param options.updatedAt - Timestamp when the task was last updated. Defaults to createdAt.
     *
     * @throws {Error} If title is empty or exceeds 200 characters, or if description exceeds 5000 characters.
     *
     * @example
     * ```typescript
     * // Create a basic task
     * const task = new Task({
     *   title: "Implement user authentication",
     *   description: "Add JWT-based authentication to the API"
     * });
     *
     * // Create a task with all options
     * const fullTask = new Task({
     *   title: "Fix critical bug",
     *   description: "Investigate and fix the payment processing bug",
     *   status: TaskStatus.IN_PROGRESS,
     *   priority: TaskPriority.URGENT,
     *   assignedTo: "550e8400-e29b-41d4-a716-446655440000",
     *   projectId: "550e8400-e29b-41d4-a716-446655440001",
     *   dueDate: new Date("2024-12-31T23:59:59Z")
     * });
     * ```
     */
    constructor(options: {
        id?: string
        title: string
        description: string
        status?: TaskStatus
        priority?: TaskPriority
        assignedTo?: string
        projectId?: string
        dueDate?: Date
        createdAt?: Date
        updatedAt?: Date
    }) {
        if (!options.title || !options.title.trim()) {
            throw new Error('Title must not be empty')
        }
        if (options.title.length > 200) {
            throw new Error('Title must not exceed 200 characters')
        }
        if (options.description.length > 5000) {
            throw new Error('Description must not exceed 5000 characters')
        }

        this.id = options.id || this.generateId()
        this.title = options.title
        this.description = options.description
        this.status = options.status ?? TaskStatus.PENDING
        this.priority = options.priority ?? TaskPriority.MEDIUM
        this.assignedTo = options.assignedTo
        this.projectId = options.projectId
        this.dueDate = options.dueDate
        this.createdAt = options.createdAt ?? new Date()
        this.updatedAt = options.updatedAt ?? this.createdAt
    }

    /**
     * Checks if this task is assigned to a user.
     *
     * @returns `true` if the task has an assigned user, `false` otherwise.
     *
     * @example
     * ```typescript
     * const task = new Task({ title: "Test", description: "Test task" });
     * console.log(task.isAssigned()); // false
     *
     * const assignedTask = new Task({
     *   title: "Test",
     *   description: "Test task",
     *   assignedTo: "user-id"
     * });
     * console.log(assignedTask.isAssigned()); // true
     * ```
     */
    public isAssigned(): boolean {
        return this.assignedTo !== undefined
    }

    /**
     * Checks if this task is overdue.
     *
     * A task is considered overdue if it has a due date that is in the past and the task
     * status is not {@link TaskStatus.COMPLETED} or {@link TaskStatus.CANCELLED}.
     *
     * @returns `true` if the task is overdue, `false` otherwise.
     *
     * @example
     * ```typescript
     * const pastDate = new Date();
     * pastDate.setDate(pastDate.getDate() - 1);
     *
     * const task = new Task({
     *   title: "Overdue task",
     *   description: "This task is overdue",
     *   dueDate: pastDate,
     *   status: TaskStatus.IN_PROGRESS
     * });
     * console.log(task.isOverdue()); // true
     * ```
     */
    public isOverdue(): boolean {
        if (!this.dueDate) {
            return false
        }
        if (
            this.status === TaskStatus.COMPLETED ||
            this.status === TaskStatus.CANCELLED
        ) {
            return false
        }
        return this.dueDate < new Date()
    }

    /**
     * Checks if this task is completed.
     *
     * @returns `true` if the task status is {@link TaskStatus.COMPLETED}, `false` otherwise.
     *
     * @example
     * ```typescript
     * const task = new Task({
     *   title: "Test",
     *   description: "Test task",
     *   status: TaskStatus.COMPLETED
     * });
     * console.log(task.isCompleted()); // true
     * ```
     */
    public isCompleted(): boolean {
        return this.status === TaskStatus.COMPLETED
    }

    /**
     * Creates a new task with an updated status.
     *
     * Since Task is immutable, this method creates a new Task instance with the
     * updated status and a new updatedAt timestamp.
     *
     * @param newStatus - The new status for the task.
     * @returns A new Task instance with the updated status.
     *
     * @example
     * ```typescript
     * const task = new Task({ title: "Test", description: "Test task" });
     * const updated = task.withStatus(TaskStatus.IN_PROGRESS);
     * console.log(updated.status === TaskStatus.IN_PROGRESS); // true
     * ```
     */
    public withStatus(newStatus: TaskStatus): Task {
        return new Task({
            id: this.id,
            title: this.title,
            description: this.description,
            status: newStatus,
            priority: this.priority,
            assignedTo: this.assignedTo,
            projectId: this.projectId,
            dueDate: this.dueDate,
            createdAt: this.createdAt,
            updatedAt: new Date(),
        })
    }

    /**
     * Creates a new task with an updated priority.
     *
     * @param newPriority - The new priority for the task.
     * @returns A new Task instance with the updated priority.
     *
     * @example
     * ```typescript
     * const task = new Task({ title: "Test", description: "Test task" });
     * const updated = task.withPriority(TaskPriority.HIGH);
     * console.log(updated.priority === TaskPriority.HIGH); // true
     * ```
     */
    public withPriority(newPriority: TaskPriority): Task {
        return new Task({
            id: this.id,
            title: this.title,
            description: this.description,
            status: this.status,
            priority: newPriority,
            assignedTo: this.assignedTo,
            projectId: this.projectId,
            dueDate: this.dueDate,
            createdAt: this.createdAt,
            updatedAt: new Date(),
        })
    }

    /**
     * Returns a string representation of this task.
     *
     * @returns A string containing the task ID, title, status, and priority.
     */
    public toString(): string {
        return `Task[id=${this.id}, title=${this.title}, status=${this.status}, priority=${this.priority}]`
    }

    private generateId(): string {
        // Simple UUID v4 generator for demo purposes
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
            const r = (Math.random() * 16) | 0
            const v = c === 'x' ? r : (r & 0x3) | 0x8
            return v.toString(16)
        })
    }
}
