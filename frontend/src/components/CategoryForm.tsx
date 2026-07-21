/**
 * Form component for adding a new expense category
 */

import React, { useState } from "react";
import { Category } from "../types";
import { TextField, Button } from "../vibes";
import { createCategory } from "../services/api";

interface CategoryFormProps {
  onCreated: (category: Category) => void;
  onCancel?: () => void;
  submitLabel?: string;
}

export function CategoryForm({
  onCreated,
  onCancel,
  submitLabel = "Add Category",
}: CategoryFormProps) {
  const [name, setName] = useState("");
  const [error, setError] = useState<string | undefined>();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!name.trim()) {
      setError("Category name is required");
      return;
    }

    setIsSubmitting(true);
    setError(undefined);
    try {
      const category = await createCategory(name.trim());
      setName("");
      onCreated(category);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create category");
    } finally {
      setIsSubmitting(false);
    }
  };

  const formStyle: React.CSSProperties = {
    display: "flex",
    flexDirection: "column",
    gap: "1rem",
  };

  const buttonGroupStyle: React.CSSProperties = {
    display: "flex",
    gap: "0.5rem",
    marginTop: "0.5rem",
  };

  return (
    <form onSubmit={handleSubmit} style={formStyle}>
      <TextField
        label="Category Name"
        type="text"
        placeholder="Enter category name"
        value={name}
        onChange={(e) => {
          setName(e.target.value);
          if (error) setError(undefined);
        }}
        error={error}
        fullWidth
        required
        autoFocus
      />

      <div style={buttonGroupStyle}>
        <Button
          type="submit"
          variant="primary"
          disabled={isSubmitting}
          fullWidth
        >
          {isSubmitting ? "Adding..." : submitLabel}
        </Button>
        {onCancel && (
          <Button
            type="button"
            variant="secondary"
            onClick={onCancel}
            disabled={isSubmitting}
          >
            Cancel
          </Button>
        )}
      </div>
    </form>
  );
}
