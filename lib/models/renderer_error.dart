class RendererError {
  final String title;
  final String message;
  final int code;
  final dynamic customError;

  const RendererError(
      {this.title = 'Undefined Error',
        this.message = "Empty Error Message",
        this.code = 1,
        this.customError});
}