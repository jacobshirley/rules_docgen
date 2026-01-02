/**
 * Task Management API
 *
 * This package provides a comprehensive API for managing tasks in a task management system.
 *
 * The API includes:
 *
 * - **Task**: Core immutable class representing a task with all its metadata
 * - **TaskStatus**: Enumeration of possible task statuses
 * - **TaskPriority**: Enumeration of priority levels
 * - **TaskService**: Interface for task management operations
 * - **InMemoryTaskService**: In-memory implementation of TaskService
 *
 * @example
 * ```typescript
 * import { Task, TaskStatus, TaskPriority, InMemoryTaskService } from './taskmanager';
 *
 * // Create a task
 * const task = new Task({
 *   title: "Implement user authentication",
 *   description: "Add JWT-based authentication to the API",
 *   priority: TaskPriority.HIGH
 * });
 *
 * // Use the service
 * const service = new InMemoryTaskService();
 * const created = service.createTask(task);
 * ```
 *
 * @packageDocumentation
 */

export { Task } from './Task';
export { TaskStatus } from './TaskStatus';
export { TaskPriority } from './TaskPriority';
export { TaskService } from './TaskService';
export { InMemoryTaskService } from './InMemoryTaskService';

