'use client';

import React from 'react';
import { cn } from '@/lib/utils';

interface TrustCardProps extends React.HTMLAttributes<HTMLDivElement> {
    variant?: 'default' | 'glass' | 'royal' | 'success';
    hoverEffect?: boolean;
}

export const TrustCard = React.forwardRef<HTMLDivElement, TrustCardProps>(
    ({ className, variant = 'glass', hoverEffect = true, children, ...props }, ref) => {
        return (
            <div
                ref={ref}
                className={cn(
                    "relative rounded-xl border transition-all duration-500 overflow-hidden",
                    // Base styles
                    variant === 'default' && "bg-void-obsidian border-white/10",
                    variant === 'glass' && "bg-void-obsidian/40 backdrop-blur-md border-white/5",
                    variant === 'royal' && "bg-royal-purple/5 border-royal-purple/20 shadow-glow-royal",
                    variant === 'success' && "bg-success-emerald/5 border-success-emerald/20 shadow-glow-success",

                    // Hover effects
                    hoverEffect && "hover:border-royal-purple/30 hover:shadow-[0_0_20px_rgba(99,102,241,0.1)] group",

                    className
                )}
                {...props}
            >
                {/* Royal corner accent */}
                <div className="absolute top-0 right-0 w-20 h-20 bg-gradient-to-bl from-royal-purple/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 pointer-events-none" />

                {/* Content */}
                <div className="relative z-10">
                    {children}
                </div>
            </div>
        );
    }
);
TrustCard.displayName = "TrustCard";

export function TrustCardHeader({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
    return <div className={cn("p-6 pb-2", className)} {...props} />;
}

export function TrustCardTitle({ className, ...props }: React.HTMLAttributes<HTMLHeadingElement>) {
    return <h3 className={cn("text-lg font-bold font-cal-sans tracking-wide text-white", className)} {...props} />;
}

export function TrustCardContent({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
    return <div className={cn("p-6 pt-2", className)} {...props} />;
}
