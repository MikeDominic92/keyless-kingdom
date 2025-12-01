'use client';

import React from 'react';
import { motion } from 'framer-motion';

interface TokenFlowProps {
    active?: boolean;
    direction?: 'right' | 'left';
    color?: string;
}

export function TokenFlow({ active = true, direction = 'right', color = '#6366F1' }: TokenFlowProps) {
    if (!active) return <div className="h-0.5 w-full bg-white/5 rounded-full" />;

    return (
        <div className="relative h-1 w-full bg-white/5 rounded-full overflow-hidden">
            <motion.div
                className="absolute top-0 h-full w-1/3 bg-gradient-to-r from-transparent via-current to-transparent opacity-70"
                style={{ color }}
                animate={{
                    x: direction === 'right' ? ['-100%', '300%'] : ['300%', '-100%'],
                }}
                transition={{
                    duration: 2,
                    repeat: Infinity,
                    ease: "linear",
                }}
            />
            {/* Particles */}
            <motion.div
                className="absolute top-0 h-full w-2 rounded-full bg-white"
                style={{ boxShadow: `0 0 10px ${color}` }}
                animate={{
                    x: direction === 'right' ? ['-100%', '1000%'] : ['1000%', '-100%'],
                }}
                transition={{
                    duration: 1.5,
                    repeat: Infinity,
                    ease: "linear",
                    delay: 0.5
                }}
            />
        </div>
    );
}
