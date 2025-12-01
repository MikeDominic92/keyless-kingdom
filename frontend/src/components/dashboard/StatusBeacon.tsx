import React from 'react';
import { cn } from '@/lib/utils';

interface StatusBeaconProps {
    status: 'healthy' | 'warning' | 'critical';
    label?: string;
    className?: string;
}

export function StatusBeacon({ status, label, className }: StatusBeaconProps) {
    const colors = {
        healthy: 'bg-emerald-500 shadow-[0_0_15px_rgba(16,185,129,0.6)]',
        warning: 'bg-amber-500 shadow-[0_0_15px_rgba(245,158,11,0.6)]',
        critical: 'bg-red-500 shadow-[0_0_15px_rgba(239,68,68,0.6)]',
    };

    const pulseColors = {
        healthy: 'bg-emerald-500',
        warning: 'bg-amber-500',
        critical: 'bg-red-500',
    };

    return (
        <div className={cn("flex items-center gap-3", className)}>
            <div className="relative flex items-center justify-center w-4 h-4">
                <span className={cn("absolute inline-flex h-full w-full rounded-full opacity-75 animate-ping", pulseColors[status])} />
                <span className={cn("relative inline-flex rounded-full h-3 w-3", colors[status])} />
            </div>
            {label && (
                <span className="text-sm font-medium text-zinc-300 tracking-wide">
                    {label}
                </span>
            )}
        </div>
    );
}
