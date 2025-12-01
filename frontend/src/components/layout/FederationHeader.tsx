import React from 'react';
import { Bell, Search, User } from 'lucide-react';

export function FederationHeader() {
    return (
        <header className="h-16 border-b border-white/10 bg-black/20 backdrop-blur-md sticky top-0 z-40 flex items-center justify-between px-8 ml-64">
            <div className="flex items-center gap-4 w-96">
                <div className="relative w-full group">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-500 group-focus-within:text-indigo-400 transition-colors" />
                    <input
                        type="text"
                        placeholder="Search federation logs..."
                        className="w-full bg-white/5 border border-white/10 rounded-full py-2 pl-10 pr-4 text-sm text-zinc-300 focus:outline-none focus:border-indigo-500/50 focus:ring-1 focus:ring-indigo-500/50 transition-all placeholder:text-zinc-600"
                    />
                </div>
            </div>

            <div className="flex items-center gap-4">
                <button className="relative p-2 rounded-full hover:bg-white/5 transition-colors text-zinc-400 hover:text-white">
                    <Bell className="w-5 h-5" />
                    <span className="absolute top-2 right-2 w-2 h-2 bg-indigo-500 rounded-full shadow-[0_0_8px_rgba(99,102,241,0.8)] animate-pulse" />
                </button>

                <div className="h-8 w-px bg-white/10" />

                <div className="flex items-center gap-3 pl-2">
                    <div className="text-right hidden md:block">
                        <p className="text-sm font-medium text-white">Admin User</p>
                        <p className="text-xs text-zinc-500">Security Architect</p>
                    </div>
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-indigo-500 to-purple-600 p-[1px]">
                        <div className="w-full h-full rounded-full bg-black flex items-center justify-center">
                            <User className="w-5 h-5 text-indigo-300" />
                        </div>
                    </div>
                </div>
            </div>
        </header>
    );
}
