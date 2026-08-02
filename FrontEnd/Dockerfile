# ==========================================
# المرحلة الأولى: بناء تطبيق Flutter Web
# ==========================================
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# نسخ ملفات الحزم أولًا للاستفادة من Docker cache
COPY pubspec.yaml pubspec.lock ./

RUN flutter pub get

# نسخ بقية مشروع الفرونت
COPY . .

# بناء Flutter Web
# داخل Docker نستخدم /api/ ليقوم Nginx بتمرير الطلبات إلى الباكند
RUN flutter build web \
    --release \
    --no-wasm-dry-run \
    --dart-define=API_BASE_URL=/api/

# ==========================================
# المرحلة الثانية: تشغيل الملفات بواسطة Nginx
# ==========================================
FROM nginx:alpine

# حذف إعدادات Nginx الافتراضية
RUN rm /etc/nginx/conf.d/default.conf

# نسخ إعداداتنا
COPY nginx.conf /etc/nginx/conf.d/default.conf

# نسخ ناتج Flutter Web
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]