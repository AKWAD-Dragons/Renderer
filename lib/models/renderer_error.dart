class RendererError {
  final String title;
  final String message;
  final int code;

  const RendererError({
    this.title = 'Undefined Error',
    this.message = "Empty Error Message",
    this.code = 1,
  });
}
