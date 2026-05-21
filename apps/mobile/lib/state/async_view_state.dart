enum AsyncViewStatus {
  idle,
  loading,
  success,
  empty,
  error,
}

class AsyncViewState<T> {
  const AsyncViewState({
    required this.status,
    this.data,
  });

  final AsyncViewStatus status;
  final T? data;

  factory AsyncViewState.idle() {
    return const AsyncViewState(status: AsyncViewStatus.idle);
  }

  factory AsyncViewState.loading() {
    return const AsyncViewState(status: AsyncViewStatus.loading);
  }

  factory AsyncViewState.success(T data) {
    return AsyncViewState(status: AsyncViewStatus.success, data: data);
  }

  factory AsyncViewState.empty() {
    return const AsyncViewState(status: AsyncViewStatus.empty);
  }

  factory AsyncViewState.error() {
    return const AsyncViewState(status: AsyncViewStatus.error);
  }
}
