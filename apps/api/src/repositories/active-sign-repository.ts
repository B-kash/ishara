import type { SignRepository } from "./sign-repository.js";

let activeSignRepository: SignRepository | undefined;

export function setSignRepository(repository: SignRepository): void {
  activeSignRepository = repository;
}

export function getSignRepository(): SignRepository {
  if (!activeSignRepository) {
    throw new Error("Sign repository is not initialized.");
  }
  return activeSignRepository;
}
