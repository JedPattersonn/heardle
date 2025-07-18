import * as React from "react"

type ToastProps = {
  title?: string
  description?: string
  variant?: "default" | "destructive"
}

export const useToast = () => {
  const toast = ({ title, description, variant = "default" }: ToastProps) => {
    // Simple console logging for now - you can integrate with sonner or another toast library
    console.log(`Toast [${variant}]: ${title} - ${description}`)
    
    // You could also show browser notifications
    if (title) {
      alert(`${title}: ${description}`)
    }
  }

  return { toast }
}