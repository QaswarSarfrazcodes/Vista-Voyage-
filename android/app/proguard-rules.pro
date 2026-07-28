# Flutter wraps the platform channel classes it needs; nothing app-specific
# to keep here beyond what plugins ship in their own consumer rules.

# flutter_local_notifications uses reflection for notification actions/receivers.
-keep class com.dexterous.** { *; }

# Supabase / gotrue / postgrest rely on Dart-side (de)serialization only —
# no Java reflection-based models to keep.
