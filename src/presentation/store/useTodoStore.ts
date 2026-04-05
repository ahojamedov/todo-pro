import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { Task } from '../../domain/entities/task';
import { taskRepository } from '../../data/repositories/task_repository';
import { authRepository } from '../../data/repositories/auth_repository';
import { User } from '@supabase/supabase-js';
import { toast } from 'sonner';
import { Language, translations } from '../../constants/translations';

export type Theme = 'dark' | 'light' | 'system';
export type FontSize = 'sm' | 'base' | 'lg';

interface TodoState {
  tasks: Task[];
  user: User | null;
  isLoading: boolean;
  
  // Settings
  language: Language;
  theme: Theme;
  fontSize: FontSize;
  
  // Auth Actions
  setUser: (user: User | null) => void;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string) => Promise<void>;
  signOut: () => Promise<void>;
  
  // Task Actions
  fetchTasks: () => Promise<void>;
  addTask: (title: string) => Promise<void>;
  toggleTask: (id: string, currentStatus: boolean) => Promise<void>;
  deleteTask: (id: string) => Promise<void>;

  // Settings Actions
  setLanguage: (lang: Language) => void;
  setTheme: (theme: Theme) => void;
  setFontSize: (size: FontSize) => void;
  t: (key: keyof typeof translations['en']) => string;
}

export const useTodoStore = create<TodoState>()(
  persist(
    (set, get) => ({
      tasks: [],
      user: null,
      isLoading: false,
      language: 'en',
      theme: 'dark',
      fontSize: 'base',

      setUser: (user) => set({ user }),

      t: (key) => {
        const lang = get().language;
        return translations[lang][key] || translations['en'][key];
      },

      setLanguage: (language) => set({ language }),
      setTheme: (theme) => set({ theme }),
      setFontSize: (fontSize) => set({ fontSize }),

      signIn: async (email, password) => {
        const { t } = get();
        try {
          set({ isLoading: true });
          const { user } = await authRepository.signIn(email, password);
          set({ user });
          toast.success(t('welcome'));
        } catch (error: any) {
          toast.error(error.message || t('failedAdd'));
          throw error;
        } finally {
          set({ isLoading: false });
        }
      },

      signUp: async (email, password) => {
        const { t } = get();
        try {
          set({ isLoading: true });
          await authRepository.signUp(email, password);
          toast.success(t('checkEmail'));
        } catch (error: any) {
          toast.error(error.message || t('failedAdd'));
          throw error;
        } finally {
          set({ isLoading: false });
        }
      },

      signOut: async () => {
        const { t } = get();
        try {
          await authRepository.signOut();
          set({ user: null, tasks: [] });
          toast.success(t('signOut'));
        } catch (error: any) {
          toast.error(error.message || t('failedAdd'));
        }
      },

      fetchTasks: async () => {
        const { user, t } = get();
        if (!user) return;
        try {
          set({ isLoading: true });
          const tasks = await taskRepository.getTasks(user.id);
          set({ tasks });
        } catch (error: any) {
          console.error('Fetch tasks error:', error);
          if (error.code === '42P01') {
            toast.error(t('tableNotFound'));
          } else {
            toast.error(error.message || t('failedFetch'));
          }
        } finally {
          set({ isLoading: false });
        }
      },

      addTask: async (title) => {
        const { user, t } = get();
        if (!user) return;
        try {
          const newTask = await taskRepository.createTask({ title, user_id: user.id });
          set((state) => ({ tasks: [newTask, ...state.tasks] }));
          toast.success(t('taskAdded'));
        } catch (error: any) {
          console.error('Add task error:', error);
          toast.error(error.message || t('failedAdd'));
        }
      },

      toggleTask: async (id, currentStatus) => {
        const { t } = get();
        try {
          await taskRepository.updateTaskStatus(id, !currentStatus);
          set((state) => ({
            tasks: state.tasks.map((t) =>
              t.id === id ? { ...t, is_completed: !currentStatus } : t
            ),
          }));
        } catch (error: any) {
          toast.error(t('failedUpdate'));
        }
      },

      deleteTask: async (id) => {
        const { t } = get();
        try {
          await taskRepository.deleteTask(id);
          set((state) => ({
            tasks: state.tasks.filter((t) => t.id !== id),
          }));
          toast.success(t('taskDeleted'));
        } catch (error: any) {
          toast.error(t('failedDelete'));
        }
      },
    }),
    {
      name: 'todo-storage',
      partialize: (state) => ({ 
        language: state.language, 
        theme: state.theme, 
        fontSize: state.fontSize 
      }),
    }
  )
);
