import { Task } from './Task'
import { TaskPriority } from './TaskPriority'
import { TaskStatus } from './TaskStatus'
import { TaskService } from './TaskService'

/**
 * A simple in-memory implementation of {@link TaskService}.
 *
 * This implementation stores tasks in memory using a Map, making it suitable
 * for testing, demos, or single-instance applications. For production use, consider
 * implementing a version that persists to a database.
 *
 * @remarks
 * This implementation is not thread-safe. For thread-safe access in a multi-threaded
 * environment, use external synchronization mechanisms.
 *
 * @example
 * ```typescript
 * const service = new InMemoryTaskService();
 * const task = new Task({ title: "Test", description: "Test task" });
 * const created = service.createTask(task);
 * const retrieved = service.getTaskById(created.id);
 * console.log(retrieved?.title); // "Test"
 * ```
 *
 * @public
 */
export class InMemoryTaskService implements TaskService {
    private readonly tasks: Map<string, Task> = new Map()

    /**
     * Creates a new InMemoryTaskService instance.
     */
    constructor() {
        // Empty constructor
    }

    /** @inheritdoc */
    public createTask(task: Task): Task {
        if (!task) {
            throw new Error('Task must not be null or undefined')
        }

        // Create a new task with a fresh ID and timestamps
        const newTask = new Task({
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            assignedTo: task.assignedTo,
            projectId: task.projectId,
            dueDate: task.dueDate,
        })

        this.tasks.set(newTask.id, newTask)
        return newTask
    }

    /** @inheritdoc */
    public getTaskById(taskId: string): Task | undefined {
        if (!taskId) {
            throw new Error('Task ID must not be null or undefined')
        }
        return this.tasks.get(taskId)
    }

    /** @inheritdoc */
    public updateTask(task: Task): Task {
        if (!task) {
            throw new Error('Task must not be null or undefined')
        }

        if (!this.tasks.has(task.id)) {
            throw new Error(`Task with ID ${task.id} does not exist`)
        }

        // Create updated task with new timestamp
        const updatedTask = new Task({
            id: task.id,
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            assignedTo: task.assignedTo,
            projectId: task.projectId,
            dueDate: task.dueDate,
            createdAt: task.createdAt,
            updatedAt: new Date(),
        })

        this.tasks.set(task.id, updatedTask)
        return updatedTask
    }

    /** @inheritdoc */
    public updateTaskStatus(taskId: string, newStatus: TaskStatus): Task {
        if (!taskId) {
            throw new Error('Task ID must not be null or undefined')
        }
        if (!newStatus) {
            throw new Error('Status must not be null or undefined')
        }

        const task = this.tasks.get(taskId)
        if (!task) {
            throw new Error(`Task with ID ${taskId} does not exist`)
        }

        const updatedTask = task.withStatus(newStatus)
        this.tasks.set(taskId, updatedTask)
        return updatedTask
    }

    /** @inheritdoc */
    public updateTaskPriority(taskId: string, newPriority: TaskPriority): Task {
        if (!taskId) {
            throw new Error('Task ID must not be null or undefined')
        }
        if (!newPriority) {
            throw new Error('Priority must not be null or undefined')
        }

        const task = this.tasks.get(taskId)
        if (!task) {
            throw new Error(`Task with ID ${taskId} does not exist`)
        }

        const updatedTask = task.withPriority(newPriority)
        this.tasks.set(taskId, updatedTask)
        return updatedTask
    }

    /** @inheritdoc */
    public assignTask(taskId: string, userId: string): Task {
        if (!taskId) {
            throw new Error('Task ID must not be null or undefined')
        }
        if (!userId) {
            throw new Error('User ID must not be null or undefined')
        }

        const task = this.tasks.get(taskId)
        if (!task) {
            throw new Error(`Task with ID ${taskId} does not exist`)
        }

        const updatedTask = new Task({
            id: task.id,
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            assignedTo: userId,
            projectId: task.projectId,
            dueDate: task.dueDate,
            createdAt: task.createdAt,
            updatedAt: new Date(),
        })

        this.tasks.set(taskId, updatedTask)
        return updatedTask
    }

    /** @inheritdoc */
    public unassignTask(taskId: string): Task {
        if (!taskId) {
            throw new Error('Task ID must not be null or undefined')
        }

        const task = this.tasks.get(taskId)
        if (!task) {
            throw new Error(`Task with ID ${taskId} does not exist`)
        }

        const updatedTask = new Task({
            id: task.id,
            title: task.title,
            description: task.description,
            status: task.status,
            priority: task.priority,
            assignedTo: undefined,
            projectId: task.projectId,
            dueDate: task.dueDate,
            createdAt: task.createdAt,
            updatedAt: new Date(),
        })

        this.tasks.set(taskId, updatedTask)
        return updatedTask
    }

    /** @inheritdoc */
    public deleteTask(taskId: string): boolean {
        if (!taskId) {
            throw new Error('Task ID must not be null or undefined')
        }
        return this.tasks.delete(taskId)
    }

    /** @inheritdoc */
    public getAllTasks(): Task[] {
        return Array.from(this.tasks.values())
    }

    /** @inheritdoc */
    public findTasks(page: number = 0, pageSize: number = 20): Task[] {
        if (page < 0) {
            throw new Error('Page must be non-negative')
        }
        if (pageSize <= 0) {
            throw new Error('Page size must be positive')
        }

        const allTasks = Array.from(this.tasks.values())
        const start = page * pageSize
        const end = Math.min(start + pageSize, allTasks.length)

        if (start >= allTasks.length) {
            return []
        }

        return allTasks.slice(start, end)
    }

    /** @inheritdoc */
    public findTasksByStatus(status: TaskStatus): Task[] {
        if (!status) {
            throw new Error('Status must not be null or undefined')
        }
        return Array.from(this.tasks.values()).filter(
            (task) => task.status === status,
        )
    }

    /** @inheritdoc */
    public findTasksByPriority(priority: TaskPriority): Task[] {
        if (!priority) {
            throw new Error('Priority must not be null or undefined')
        }
        return Array.from(this.tasks.values()).filter(
            (task) => task.priority === priority,
        )
    }

    /** @inheritdoc */
    public findTasksByAssignedUser(userId: string): Task[] {
        if (!userId) {
            throw new Error('User ID must not be null or undefined')
        }
        return Array.from(this.tasks.values()).filter(
            (task) => task.assignedTo === userId,
        )
    }

    /** @inheritdoc */
    public findTasksByProject(projectId: string): Task[] {
        if (!projectId) {
            throw new Error('Project ID must not be null or undefined')
        }
        return Array.from(this.tasks.values()).filter(
            (task) => task.projectId === projectId,
        )
    }

    /** @inheritdoc */
    public findOverdueTasks(): Task[] {
        return Array.from(this.tasks.values()).filter((task) =>
            task.isOverdue(),
        )
    }

    /** @inheritdoc */
    public countTasks(): number {
        return this.tasks.size
    }

    /** @inheritdoc */
    public countTasksByStatus(status: TaskStatus): number {
        if (!status) {
            throw new Error('Status must not be null or undefined')
        }
        return Array.from(this.tasks.values()).filter(
            (task) => task.status === status,
        ).length
    }
}
