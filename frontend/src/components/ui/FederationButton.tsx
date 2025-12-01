'use client';

import React from 'react';
import { cn } from '@/lib/utils';
import { cva, type VariantProps } from 'class-variance-authority';
import { Loader2 } from 'lucide-react';

const buttonVariants = cva(
    "relative inline-flex items-center justify-center whitespace-nowrap rounded-lg text-sm font-medium transition-all duration-300 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-royal-purple/50 disabled:pointer-events-none disabled:opacity-50 overflow-hidden",
    {
        variants: {
            variant: {
                primary: "bg-royal-purple text-white hover:bg-royal-purple/90 shadow-glow-royal hover:shadow-[0_0_20px_rgba(99,102,241,0.4)]",
                secondary: "bg-void-obsidian text-text-primary border border-white/10 hover:bg-white/5 hover:border-white/20",
                outline: "border border-royal-purple/30 text-royal-purple hover:bg-royal-purple/10",
                ghost: "hover:bg-white/5 text-text-secondary hover:text-white",
                aws: "bg-aws-orange/10 text-aws-orange border border-aws-orange/20 hover:bg-aws-orange/20 hover:shadow-[0_0_15px_rgba(255,153,0,0.2)]",
                gcp: "bg-gcp-blue/10 text-gcp-blue border border-gcp-blue/20 hover:bg-gcp-blue/20 hover:shadow-[0_0_15px_rgba(66,133,244,0.2)]",
                azure: "bg-azure-blue/10 text-azure-blue border border-azure-blue/20 hover:bg-azure-blue/20 hover:shadow-[0_0_15px_rgba(0,120,212,0.2)]",
            },
            size: {
                default: "h-10 px-4 py-2",
                sm: "h-9 rounded-md px-3",
                lg: "h-11 rounded-md px-8",
                icon: "h-10 w-10",
            },
        },
        defaultVariants: {
            variant: "primary",
            size: "default",
        },
    }
);

export interface FederationButtonProps
    extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
    loading?: boolean;
}

export const FederationButton = React.forwardRef<HTMLButtonElement, FederationButtonProps>(
    ({ className, variant, size, loading, children, ...props }, ref) => {
        return (
            <button
                className={cn(buttonVariants({ variant, size, className }))}
                ref={ref}
                disabled={loading || props.disabled}
                {...props}
            >
                {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                <span className="relative z-10 flex items-center gap-2">
                    {children}
                </span>
            </button>
        );
    }
);
FederationButton.displayName = "FederationButton";
