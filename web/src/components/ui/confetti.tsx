"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

interface Particle {
  id: number;
  x: number;
  y: number;
  color: string;
  size: number;
  rotation: number;
  vx: number;
  vy: number;
}

interface ConfettiProps {
  trigger: boolean;
  duration?: number;
  particleCount?: number;
  colors?: string[];
}

export default function Confetti({
  trigger,
  duration = 3000,
  particleCount = 50,
  colors = [
    "#FFD700",
    "#FF6B6B",
    "#4ECDC4",
    "#45B7D1",
    "#96CEB4",
    "#FFDCE6",
    "#C7CEEA",
  ],
}: ConfettiProps) {
  const [particles, setParticles] = useState<Particle[]>([]);
  const [isActive, setIsActive] = useState(false);

  useEffect(() => {
    if (trigger) {
      setIsActive(true);

      // Create particles
      const newParticles: Particle[] = Array.from(
        { length: particleCount },
        (_, i) => ({
          id: i,
          x: Math.random() * 100,
          y: 100 + Math.random() * 20,
          color: colors[Math.floor(Math.random() * colors.length)],
          size: Math.random() * 8 + 4,
          rotation: Math.random() * 360,
          vx: (Math.random() - 0.5) * 40,
          vy: -(Math.random() * 50 + 30),
        })
      );

      setParticles(newParticles);

      // Clean up after duration
      const timer = setTimeout(() => {
        setIsActive(false);
        setParticles([]);
      }, duration);

      return () => clearTimeout(timer);
    }
  }, [trigger, duration, particleCount, colors]);

  if (!isActive) return null;

  return (
    <div className="fixed inset-0 pointer-events-none z-50 overflow-hidden">
      <AnimatePresence>
        {particles.map((particle) => (
          <motion.div
            key={particle.id}
            className="absolute"
            style={{
              backgroundColor: particle.color,
              width: particle.size,
              height: particle.size,
              borderRadius: Math.random() > 0.5 ? "50%" : "0%",
            }}
            initial={{
              x: `${particle.x}vw`,
              y: `${particle.y}vh`,
              rotate: particle.rotation,
              opacity: 1,
            }}
            animate={{
              x: `${particle.x + particle.vx}vw`,
              y: `${particle.y + particle.vy * 3}vh`,
              rotate: particle.rotation + 360,
              opacity: 0,
            }}
            transition={{
              duration: duration / 1000,
              ease: "easeOut",
            }}
          />
        ))}
      </AnimatePresence>
    </div>
  );
}

// Simplified version for smaller celebrations
export function MiniConfetti({
  trigger,
  x = 50,
  y = 50,
}: {
  trigger: boolean;
  x?: number;
  y?: number;
}) {
  const [particles, setParticles] = useState<Particle[]>([]);

  useEffect(() => {
    if (trigger) {
      const colors = ["#FFD700", "#FF6B6B", "#4ECDC4", "#45B7D1"];
      const newParticles: Particle[] = Array.from({ length: 12 }, (_, i) => ({
        id: i,
        x,
        y,
        color: colors[Math.floor(Math.random() * colors.length)],
        size: Math.random() * 4 + 2,
        rotation: Math.random() * 360,
        vx: (Math.random() - 0.5) * 20,
        vy: -(Math.random() * 20 + 10),
      }));

      setParticles(newParticles);

      const timer = setTimeout(() => {
        setParticles([]);
      }, 1500);

      return () => clearTimeout(timer);
    }
  }, [trigger, x, y]);

  return (
    <div className="absolute inset-0 pointer-events-none overflow-hidden">
      <AnimatePresence>
        {particles.map((particle) => (
          <motion.div
            key={particle.id}
            className="absolute"
            style={{
              backgroundColor: particle.color,
              width: particle.size,
              height: particle.size,
              borderRadius: "50%",
              left: `${particle.x}%`,
              top: `${particle.y}%`,
            }}
            initial={{
              scale: 0,
              opacity: 1,
            }}
            animate={{
              x: particle.vx,
              y: particle.vy,
              scale: 1,
              opacity: 0,
            }}
            transition={{
              duration: 1.5,
              ease: "easeOut",
            }}
          />
        ))}
      </AnimatePresence>
    </div>
  );
}
