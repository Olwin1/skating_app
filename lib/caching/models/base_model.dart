abstract class BaseModel<T> {
  Map<String, Object> toJson();
  T fromJson(final Map<String, Object> json);
}
