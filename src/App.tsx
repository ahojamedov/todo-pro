import React, { useEffect, useState } from 'react';
import { Toaster, toast } from 'sonner';
import { useTodoStore, Theme, FontSize } from './presentation/store/useTodoStore';
import { supabase } from './data/datasources/supabase_client';
import { 
  Plus, 
  Trash2, 
  CheckCircle2, 
  Circle, 
  LogOut, 
  Loader2,
  ClipboardList,
  Mail,
  Lock,
  Settings,
  X,
  Sun,
  Moon,
  Monitor,
  Type,
  Languages
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { Language } from './constants/translations';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export default function App() {
  const { 
    user, 
    setUser, 
    tasks, 
    isLoading, 
    signIn, 
    signUp, 
    signOut, 
    fetchTasks, 
    addTask, 
    toggleTask, 
    deleteTask,
    language,
    setLanguage,
    theme,
    setTheme,
    fontSize,
    setFontSize,
    t
  } = useTodoStore();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [newTaskTitle, setNewTaskTitle] = useState('');
  const [isSignUp, setIsSignUp] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);

  // Theme logic
  useEffect(() => {
    const root = window.document.documentElement;
    const applyTheme = (t: Theme) => {
      root.classList.remove('light', 'dark');
      if (t === 'system') {
        const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
        root.classList.add(systemTheme);
      } else {
        root.classList.add(t);
      }
    };
    applyTheme(theme);
  }, [theme]);

  // Font size logic
  useEffect(() => {
    const root = window.document.documentElement;
    root.style.fontSize = fontSize === 'sm' ? '14px' : fontSize === 'lg' ? '18px' : '16px';
  }, [fontSize]);

  const isConfigured = 
    (import.meta.env.VITE_SUPABASE_URL && import.meta.env.VITE_SUPABASE_URL !== 'https://your-project-id.supabase.co') ||
    (import.meta.env.VITE_SUPABASE_ANON_KEY && import.meta.env.VITE_SUPABASE_ANON_KEY !== 'your-anon-key') ||
    true; // Force configured since we hardcoded the values as defaults

  useEffect(() => {
    if (!isConfigured) return;
    
    // Check initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setUser(session?.user ?? null);
    });

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });

    return () => subscription.unsubscribe();
  }, [setUser, isConfigured]);

  useEffect(() => {
    if (user && isConfigured) {
      fetchTasks();
    }
  }, [user, fetchTasks, isConfigured]);

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    if (isSignUp) {
      await signUp(email, password);
    } else {
      await signIn(email, password);
    }
  };

  const handleAddTask = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTaskTitle.trim()) return;
    await addTask(newTaskTitle);
    setNewTaskTitle('');
  };

  if (!isConfigured) {
    return (
      <div className="min-h-screen bg-[#0A0A0A] text-white flex items-center justify-center p-4 font-sans">
        <motion.div 
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          className="w-full max-w-lg bg-[#141414] border border-amber-500/20 rounded-3xl p-8 shadow-2xl"
        >
          <div className="flex flex-col items-center mb-6">
            <div className="w-16 h-16 bg-amber-500/10 rounded-2xl flex items-center justify-center mb-4 border border-amber-500/20">
              <Lock className="text-amber-500 w-8 h-8" />
            </div>
            <h1 className="text-2xl font-bold tracking-tight">My ToDo Setup Required</h1>
            <p className="text-zinc-500 text-center mt-2">
              To use this app, you need to connect your own Supabase project.
            </p>
          </div>

          <div className="space-y-6">
            <div className="bg-[#1A1A1A] border border-white/5 rounded-2xl p-5 space-y-4">
              <h3 className="text-sm font-semibold uppercase tracking-wider text-zinc-400">Step 1: Get your keys</h3>
              <p className="text-sm text-zinc-500">
                Go to your <a href="https://supabase.com/dashboard" target="_blank" rel="noopener noreferrer" className="text-emerald-500 hover:underline">Supabase Dashboard</a> → <b>Project Settings</b> → <b>API</b>.
              </p>
              <div className="grid grid-cols-1 gap-2 text-xs font-mono">
                <div className="bg-black/40 p-3 rounded-lg border border-white/5">
                  <span className="text-emerald-500">Project URL</span>
                  <div className="text-zinc-400 mt-1 truncate">https://your-project.supabase.co</div>
                </div>
                <div className="bg-black/40 p-3 rounded-lg border border-white/5">
                  <span className="text-emerald-500">Anon Key</span>
                  <div className="text-zinc-400 mt-1 truncate">eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...</div>
                </div>
              </div>
            </div>

            <div className="bg-[#1A1A1A] border border-white/5 rounded-2xl p-5 space-y-4">
              <h3 className="text-sm font-semibold uppercase tracking-wider text-zinc-400">Step 2: Set Secrets in AI Studio</h3>
              <p className="text-sm text-zinc-500">
                Open the <b>Secrets</b> panel in the AI Studio sidebar and add:
              </p>
              <ul className="list-disc list-inside text-sm text-zinc-400 space-y-1">
                <li><code className="text-emerald-500">VITE_SUPABASE_URL</code></li>
                <li><code className="text-emerald-500">VITE_SUPABASE_ANON_KEY</code></li>
              </ul>
            </div>

            <div className="text-center text-xs text-zinc-600">
              Once set, the app will automatically refresh and unlock the login screen.
            </div>
          </div>
        </motion.div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-white dark:bg-[#0A0A0A] text-black dark:text-white flex items-center justify-center p-4 font-sans transition-colors duration-300">
        <Toaster position="top-center" theme={theme === 'system' ? 'dark' : theme} />
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="w-full max-w-md bg-zinc-50 dark:bg-[#141414] border border-black/5 dark:border-white/10 rounded-2xl p-8 shadow-2xl"
        >
          <div className="flex flex-col items-center mb-8">
            <div className="w-16 h-16 bg-emerald-500/10 rounded-2xl flex items-center justify-center mb-4 border border-emerald-500/20">
              <ClipboardList className="text-emerald-500 w-8 h-8" />
            </div>
            <h1 className="text-2xl font-bold tracking-tight">My ToDo</h1>
            <p className="text-zinc-500 text-sm mt-1">
              {isSignUp ? t('signUp') : t('signIn')}
            </p>
          </div>

          <form onSubmit={handleAuth} className="space-y-4">
            <div className="space-y-2">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-500">{t('email')}</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-500" />
                <input 
                  type="email" 
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@example.com"
                  className="w-full bg-white dark:bg-[#1A1A1A] border border-black/10 dark:border-white/5 rounded-xl py-3 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 transition-all"
                  required
                />
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-xs font-semibold uppercase tracking-wider text-zinc-500">{t('password')}</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-500" />
                <input 
                  type="password" 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full bg-white dark:bg-[#1A1A1A] border border-black/10 dark:border-white/5 rounded-xl py-3 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 transition-all"
                  required
                />
              </div>
            </div>

            <button 
              type="submit" 
              disabled={isLoading}
              className="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-3 rounded-xl transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? <Loader2 className="w-5 h-5 animate-spin" /> : (isSignUp ? t('createAccount') : t('signIn'))}
            </button>
          </form>

          <div className="mt-6 text-center">
            <button 
              onClick={() => setIsSignUp(!isSignUp)}
              className="text-sm text-zinc-400 hover:text-black dark:hover:text-white transition-colors"
            >
              {isSignUp ? t('alreadyHaveAccount') : t('dontHaveAccount')}
            </button>
          </div>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-white dark:bg-[#0A0A0A] text-black dark:text-white font-sans transition-colors duration-300">
      <Toaster position="top-center" theme={theme === 'system' ? 'dark' : theme} />
      
      {/* Header */}
      <header className="border-b border-black/5 dark:border-white/5 bg-white/80 dark:bg-[#0A0A0A]/80 backdrop-blur-md sticky top-0 z-10">
        <div className="max-w-3xl mx-auto px-4 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <ClipboardList className="text-emerald-500 w-6 h-6" />
            <span className="font-bold tracking-tight">My ToDo</span>
          </div>
          <div className="flex items-center gap-2">
            <button 
              onClick={() => setIsSettingsOpen(true)}
              className="p-2 hover:bg-black/5 dark:hover:bg-white/5 rounded-lg transition-colors text-zinc-400 hover:text-black dark:hover:text-white"
              title={t('settings')}
            >
              <Settings className="w-5 h-5" />
            </button>
            <button 
              onClick={signOut}
              className="p-2 hover:bg-black/5 dark:hover:bg-white/5 rounded-lg transition-colors text-zinc-400 hover:text-black dark:hover:text-white"
              title={t('signOut')}
            >
              <LogOut className="w-5 h-5" />
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-3xl mx-auto px-4 py-8">
        {/* Add Task Form */}
        <form onSubmit={handleAddTask} className="mb-8">
          <div className="relative group">
            <input 
              type="text" 
              value={newTaskTitle}
              onChange={(e) => setNewTaskTitle(e.target.value)}
              placeholder={t('placeholder')}
              className="w-full bg-zinc-50 dark:bg-[#141414] border border-black/10 dark:border-white/10 rounded-2xl py-4 pl-6 pr-16 focus:outline-none focus:ring-2 focus:ring-emerald-500/50 transition-all text-lg"
            />
            <button 
              type="submit"
              className="absolute right-2 top-1/2 -translate-y-1/2 bg-emerald-600 hover:bg-emerald-500 p-2 rounded-xl transition-all group-focus-within:scale-105"
            >
              <Plus className="w-6 h-6 text-white" />
            </button>
          </div>
        </form>

        {/* Task List */}
        <div className="space-y-3">
          {isLoading && tasks.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20 text-zinc-500">
              <Loader2 className="w-8 h-8 animate-spin mb-2" />
              <p>Loading...</p>
            </div>
          ) : tasks.length === 0 ? (
            <div className="text-center py-20 border-2 border-dashed border-black/5 dark:border-white/5 rounded-3xl">
              <ClipboardList className="w-12 h-12 text-zinc-300 dark:text-zinc-700 mx-auto mb-4" />
              <h3 className="text-zinc-400 font-medium">{t('noTasks')}</h3>
              <p className="text-zinc-600 text-sm mb-6">{t('addFirst')}</p>
              
              <div className="bg-zinc-50 dark:bg-[#1A1A1A] max-w-sm mx-auto p-4 rounded-xl border border-black/5 dark:border-white/5 text-left">
                <p className="text-xs font-bold text-amber-500 uppercase tracking-widest mb-2">{t('troubleshooting')}</p>
                <p className="text-xs text-zinc-500 leading-relaxed">
                  {t('sqlHelp')}
                </p>
                <button 
                  onClick={() => {
                    const sql = `create table tasks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  title text not null,
  is_completed boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table tasks enable row level security;

create policy "Users can manage their own tasks" 
  on tasks for all 
  using (auth.uid() = user_id);`;
                    navigator.clipboard.writeText(sql);
                    toast.success('SQL copied to clipboard!');
                  }}
                  className="mt-3 text-xs text-emerald-500 hover:text-emerald-400 font-medium flex items-center gap-1"
                >
                  {t('copySql')}
                </button>
              </div>
            </div>
          ) : (
            <AnimatePresence mode="popLayout">
              {tasks.map((task) => (
                <motion.div
                  key={task.id}
                  layout
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: 20 }}
                  className={cn(
                    "group flex items-center gap-4 bg-zinc-50 dark:bg-[#141414] border border-black/5 dark:border-white/5 p-4 rounded-2xl transition-all hover:border-black/10 dark:hover:border-white/10",
                    task.is_completed && "opacity-60"
                  )}
                >
                  <button 
                    onClick={() => toggleTask(task.id, task.is_completed)}
                    className="flex-shrink-0 transition-transform active:scale-90"
                  >
                    {task.is_completed ? (
                      <CheckCircle2 className="w-6 h-6 text-emerald-500" />
                    ) : (
                      <Circle className="w-6 h-6 text-zinc-300 dark:text-zinc-600 group-hover:text-zinc-400" />
                    )}
                  </button>
                  
                  <span className={cn(
                    "flex-grow text-zinc-800 dark:text-zinc-200 transition-all",
                    task.is_completed && "line-through text-zinc-500"
                  )}>
                    {task.title}
                  </span>

                  <button 
                    onClick={() => deleteTask(task.id)}
                    className="opacity-0 group-hover:opacity-100 p-2 hover:bg-red-500/10 hover:text-red-500 rounded-lg transition-all text-zinc-400 dark:text-zinc-500"
                  >
                    <Trash2 className="w-5 h-5" />
                  </button>
                </motion.div>
              ))}
            </AnimatePresence>
          )}
        </div>
      </main>

      {/* Settings Panel */}
      <AnimatePresence>
        {isSettingsOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsSettingsOpen(false)}
              className="fixed inset-0 bg-black/40 backdrop-blur-sm z-40"
            />
            <motion.div 
              initial={{ x: '100%' }}
              animate={{ x: 0 }}
              exit={{ x: '100%' }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-sm bg-white dark:bg-[#0F0F0F] border-l border-black/5 dark:border-white/5 z-50 shadow-2xl p-6"
            >
              <div className="flex items-center justify-between mb-8">
                <h2 className="text-xl font-bold flex items-center gap-2">
                  <Settings className="w-5 h-5 text-emerald-500" />
                  {t('settings')}
                </h2>
                <button 
                  onClick={() => setIsSettingsOpen(false)}
                  className="p-2 hover:bg-black/5 dark:hover:bg-white/5 rounded-full transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="space-y-8">
                {/* Language */}
                <section className="space-y-4">
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-zinc-500">
                    <Languages className="w-4 h-4" />
                    {t('language')}
                  </div>
                  <div className="grid grid-cols-2 gap-2">
                    {[
                      { id: 'en', label: 'English' },
                      { id: 'ru', label: 'Русский' },
                      { id: 'tk', label: 'Türkmen' },
                      { id: 'zh', label: '中文' }
                    ].map((lang) => (
                      <button
                        key={lang.id}
                        onClick={() => setLanguage(lang.id as Language)}
                        className={cn(
                          "py-2 px-4 rounded-xl text-sm font-medium transition-all border",
                          language === lang.id 
                            ? "bg-emerald-500/10 border-emerald-500/50 text-emerald-500" 
                            : "bg-black/5 dark:bg-white/5 border-transparent text-zinc-500 hover:text-zinc-200"
                        )}
                      >
                        {lang.label}
                      </button>
                    ))}
                  </div>
                </section>

                {/* Theme */}
                <section className="space-y-4">
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-zinc-500">
                    <Sun className="w-4 h-4" />
                    {t('theme')}
                  </div>
                  <div className="grid grid-cols-3 gap-2">
                    {[
                      { id: 'light', icon: Sun, label: t('light') },
                      { id: 'dark', icon: Moon, label: t('dark') },
                      { id: 'system', icon: Monitor, label: t('system') }
                    ].map((item) => (
                      <button
                        key={item.id}
                        onClick={() => setTheme(item.id as Theme)}
                        className={cn(
                          "flex flex-col items-center gap-2 py-3 rounded-xl text-xs font-medium transition-all border",
                          theme === item.id 
                            ? "bg-emerald-500/10 border-emerald-500/50 text-emerald-500" 
                            : "bg-black/5 dark:bg-white/5 border-transparent text-zinc-500 hover:text-zinc-200"
                        )}
                      >
                        <item.icon className="w-4 h-4" />
                        {item.label}
                      </button>
                    ))}
                  </div>
                </section>

                {/* Font Size */}
                <section className="space-y-4">
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-zinc-500">
                    <Type className="w-4 h-4" />
                    {t('fontSize')}
                  </div>
                  <div className="grid grid-cols-3 gap-2">
                    {[
                      { id: 'sm', label: t('small') },
                      { id: 'base', label: t('medium') },
                      { id: 'lg', label: t('large') }
                    ].map((size) => (
                      <button
                        key={size.id}
                        onClick={() => setFontSize(size.id as FontSize)}
                        className={cn(
                          "py-2 rounded-xl text-sm font-medium transition-all border",
                          fontSize === size.id 
                            ? "bg-emerald-500/10 border-emerald-500/50 text-emerald-500" 
                            : "bg-black/5 dark:bg-white/5 border-transparent text-zinc-500 hover:text-zinc-200"
                        )}
                      >
                        {size.label}
                      </button>
                    ))}
                  </div>
                </section>
              </div>

              <div className="absolute bottom-8 left-6 right-6">
                <div className="p-4 bg-emerald-500/5 border border-emerald-500/10 rounded-2xl">
                  <p className="text-[10px] text-zinc-500 text-center leading-relaxed">
                    My ToDo v1.2.0<br/>
                    Crafted with Clean Architecture
                  </p>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}
