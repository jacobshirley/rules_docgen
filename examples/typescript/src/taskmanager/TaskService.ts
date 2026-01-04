import { Task } from './Task'
import { TaskPriority } from './TaskPriority'
import { TaskStatus } from './TaskStatus'

/**
 * Service interface for managing tasks.
 *
 * This service provides operations for creating, reading, updating, and deleting tasks.
 * It also provides methods for querying tasks by various criteria such as status, priority,
 * assigned user, and project.
 *
 * @remarks
 * Implementations of this interface should be thread-safe if they are to be used in
 * a multi-threaded environment (though JavaScript is single-threaded, this applies to
 * concurrent access patterns).
 *
 * @example
 * ```typescript
 * const service = new InMemoryTaskService();
 *
 * // Create a new task
 * const task = new Task({
 *   title: "Implement user authentication",
 *   description: "Add JWT-based authentication",
 *   priority: TaskPriority.HIGH
 * });
 * const created = service.createTask(task);
 *
 * // Find tasks by status
 * const inProgress = service.findTasksByStatus(TaskStatus.IN_PROGRESS);
 *
 * // Update task status
 * const updated = service.updateTaskStatus(created.id, TaskStatus.COMPLETED);
 * ```
 *
 * @public
 */
export interface TaskService {
    /**
     * Creates a new task.
     *
     * The task will be persisted and assigned a unique identifier. If the task already
     * has an ID, it will be ignored and a new ID will be generated.
     *
     * @param task - The task to create. Must not be null or undefined.
     * @returns The created task with its assigned ID and timestamps.
     * @throws {Error} If the task data is invalid.
     */
    createTask(task: Task): Task

    /**
     * Retrieves a task by its unique identifier.
     *
     * @param taskId - The unique identifier of the task. Must not be null or undefined.
     * @returns The task if found, or undefined if not found.
     */
    getTaskById(taskId: string): Task | undefined

    /**
     * Updates an existing task.
     *
     * The task with the given ID will be replaced with the provided task data.
     * The task ID in the provided task must match an existing task, or an exception
     * will be thrown.
     *
     * @param task - The task with updated data. Must not be null or undefined and must have a valid ID.
     * @returns The updated task.
     * @throws {Error} If the task ID is invalid or the task doesn't exist.
     */
    updateTask(task: Task): Task

    /**
     * Updates the status of a task.
     *
     * This is a convenience method for updating only the task status without needing
     * to retrieve and rebuild the entire task object.
     *
     * @param taskId - The unique identifier of the task to update. Must not be null or undefined.
     * @param newStatus - The new status for the task. Must not be null or undefined.
     * @returns The updated task.
     * @throws {Error} If the task doesn't exist.
     */
    updateTaskStatus(taskId: string, newStatus: TaskStatus): Task

    /**
     * Updates the priority of a task.
     *
     * This is a convenience method for updating only the task priority.
     *
     * @param taskId - The unique identifier of the task to update. Must not be null or undefined.
     * @param newPriority - The new priority for the task. Must not be null or undefined.
     * @returns The updated task.
     * @throws {Error} If the task doesn't exist.
     */
    updateTaskPriority(taskId: string, newPriority: TaskPriority): Task

    /**
     * Assigns a task to a user.
     *
     * @param taskId - The unique identifier of the task. Must not be null or undefined.
     * @param userId - The unique identifier of the user to assign. Must not be null or undefined.
     * @returns The updated task.
     * @throws {Error} If the task doesn't exist.
     */
    assignTask(taskId: string, userId: string): Task

    /**
     * Unassigns a task from its current user.
     *
     * @param taskId - The unique identifier of the task. Must not be null or undefined.
     * @returns The updated task.
     * @throws {Error} If the task doesn't exist.
     */
    unassignTask(taskId: string): Task

    /**
     * Deletes a task by its unique identifier.
     *
     * This operation is permanent and cannot be undone. The task will be removed
     * from all associated projects and user assignments.
     *
     * @param taskId - The unique identifier of the task to delete. Must not be null or undefined.
     * @returns `true` if the task was deleted, `false` if it didn't exist.
     */
    deleteTask(taskId: string): boolean

    /**
     * Retrieves all tasks.
     *
     * This method returns all tasks in the system. For large datasets, consider using
     * the paginated version {@link TaskService.findTasks}.
     *
     * @returns A list of all tasks. Never null or undefined but may be empty.
     */
    getAllTasks(): Task[]

    /**
     * Retrieves tasks with pagination support.
     *
     * @param page - The page number (0-indexed). Defaults to 0.
     * @param pageSize - The number of tasks per page. Must be positive. Defaults to 20.
     * @returns A list of tasks for the specified page.
     * @throws {Error} If page is negative or pageSize is not positive.
     */
    findTasks(page?: number, pageSize?: number): Task[]

    /**
     * Finds tasks by their status.
     *
     * @param status - The status to filter by. Must not be null or undefined.
     * @returns A list of tasks with the specified status. Never null or undefined but may be empty.
     */
    findTasksByStatus(status: TaskStatus): Task[]

    /**
     * Finds tasks by their priority.
     *
     * @param priority - The priority to filter by. Must not be null or undefined.
     * @returns A list of tasks with the specified priority. Never null or undefined but may be empty.
     */
    findTasksByPriority(priority: TaskPriority): Task[]

    /**
     * Finds tasks assigned to a specific user.
     *
     * @param userId - The unique identifier of the user. Must not be null or undefined.
     * @returns A list of tasks assigned to the user. Never null or undefined but may be empty.
     */
    findTasksByAssignedUser(userId: string): Task[]

    /**
     * Finds tasks belonging to a specific project.
     *
     * @param projectId - The unique identifier of the project. Must not be null or undefined.
     * @returns A list of tasks in the project. Never null or undefined but may be empty.
     */
    findTasksByProject(projectId: string): Task[]

    /**
     * Finds tasks that are overdue.
     *
     * A task is considered overdue if it has a due date that is in the past and the task
     * status is not {@link TaskStatus.COMPLETED} or {@link TaskStatus.CANCELLED}.
     *
     * @returns A list of overdue tasks. Never null or undefined but may be empty.
     */
    findOverdueTasks(): Task[]

    /**
     * Counts the total number of tasks.
     *
     * @returns The total number of tasks in the system.
     */
    countTasks(): number

    /**
     * Counts tasks by status.
     *
     * @param status - The status to count. Must not be null or undefined.
     * @returns The number of tasks with the specified status.
     */
    countTasksByStatus(status: TaskStatus): number
}
