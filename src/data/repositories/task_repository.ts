import { supabase } from '../datasources/supabase_client';
import { Task, CreateTaskDto } from '../../domain/entities/task';

export class TaskRepository {
  async getTasks(userId: string): Promise<Task[]> {
    const { data, error } = await supabase
      .from('tasks')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  }

  async createTask(task: CreateTaskDto): Promise<Task> {
    const { data, error } = await supabase
      .from('tasks')
      .insert([task])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async updateTaskStatus(id: string, isCompleted: boolean): Promise<void> {
    const { error } = await supabase
      .from('tasks')
      .update({ is_completed: isCompleted })
      .eq('id', id);

    if (error) throw error;
  }

  async deleteTask(id: string): Promise<void> {
    const { error } = await supabase
      .from('tasks')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }
}

export const taskRepository = new TaskRepository();
