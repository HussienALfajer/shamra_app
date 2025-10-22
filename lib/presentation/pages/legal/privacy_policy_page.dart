// lib/presentation/pages/legal/privacy_policy_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/common_widgets.dart';

/// Privacy Policy screen (Arabic content).
/// All comments are in English by request.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const companyName = 'شمرا';
    const lastUpdated = 'آخر تحديث: 21 أكتوبر 2025';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'سياسة الخصوصية'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _LegalHeader(title: 'سياسة الخصوصية', subtitle: '$companyName', lastUpdated: lastUpdated),

            _SectionTitle('1) لمحة عامة'),
            _SectionBody(
              'تحترم $companyName خصوصيتك وتلتزم بحماية بياناتك الشخصية. توضّح هذه السياسة طبيعة البيانات التي نجمعها وكيفية استخدامها ومشاركتها وخياراتك حيالها.',
            ),

            _SectionTitle('2) الجهة المسؤولة عن معالجة البيانات'),
            _SectionBody(
              '$companyName هي الجهة المسؤولة عن تحديد أغراض ووسائل معالجة البيانات الشخصية التي تُجمع عبر هذا التطبيق.',
            ),

            _SectionTitle('3) البيانات التي نجمعها'),
            _Bullets(items: const [
              'بيانات الهوية والتواصل: الاسم، رقم الهاتف، الفرع المختار.',
              'بيانات الحساب والمصادقة: رموز التحقق (OTP)، سجلات الدخول.',
              'بيانات تقنية: نوع الجهاز، نظام التشغيل، مُعرّفات الأجهزة لأغراض الأمان والتحليلات.',
              'بيانات الاستخدام: تفاعلاتك داخل التطبيق، الصفحات/الشاشات التي تزورها، عمليات البحث والطلبات.',
              'الملفات المؤقتة وملفات تعريف الارتباط (Cookies) وتقنيات مشابهة.',
              'بيانات الموقع التقريبية (إن وافقت على ذلك داخل الجهاز).',
            ]),

            _SectionTitle('4) كيف نستخدم بياناتك'),
            _Bullets(items: const [
              'إنشاء الحساب وتقديم خدمات التطبيق وتشغيل الميزات.',
              'إرسال رموز التحقق والإشعارات اللازمة لتأمين الحساب وتنفيذ الطلبات.',
              'تحسين التجربة وتحليل الأداء واستكشاف الأخطاء وإصلاحها.',
              'عرض محتوى/عروض مناسبة بحسب تفضيلاتك (حيثما كان ذلك مشروعًا وبحسب موافقاتك).',
              'الامتثال للالتزامات القانونية والرقابية ومنع الاحتيال وإساءة الاستخدام.',
            ]),

            _SectionTitle('5) الأسس القانونية للمعالجة'),
            _Bullets(items: const [
              'تنفيذ العقد: لتقديم الخدمة التي تطلبها عبر التطبيق.',
              'الموافقة: لبعض الميزات الاختيارية مثل الرسائل التسويقية أو الوصول للموقع.',
              'المصلحة المشروعة: لتحسين الأمان والأداء وتجربة المستخدم.',
              'الالتزام القانوني: للحفاظ على السجلات والرد على الطلبات الرسمية.',
            ]),

            _SectionTitle('6) مشاركة البيانات'),
            _Bullets(items: const [
              'مزوّدو الخدمة: الدفع، التحليلات، الإشعارات، الاستضافة… وفق اتفاقيات حماية البيانات.',
              'شركات شقيقة/تابعة ضمن مجموعة $companyName عند الضرورة ووفق القانون.',
              'الجهات الرسمية عند الطلب القانوني الملزم أو الدفاع عن الحقوق.',
            ]),

            _SectionTitle('7) الاحتفاظ بالبيانات'),
            _SectionBody(
              'نحتفظ بالبيانات الشخصية للمدة اللازمة لتحقيق الأغراض المذكورة في هذه السياسة، '
                  'أو وفق ما تقتضيه القوانين النافذة. عند انتهاء الغرض، نعمل على حذفها أو إخفاء هويتها بصورة آمنة.',
            ),

            _SectionTitle('8) الأمان'),
            _SectionBody(
              'نطبّق إجراءات تقنية وتنظيمية مناسبة لحماية البيانات من الوصول غير المصرّح به أو الفقدان أو التغيير. '
                  'مع ذلك لا يمكن ضمان الأمان بنسبة 100% عبر الإنترنت.',
            ),

            _SectionTitle('9) حقوقك'),
            _Bullets(items: const [
              'الاطلاع على بياناتك والحصول على نسخة منها.',
              'طلب تصحيح البيانات غير الدقيقة أو إكمال الناقص منها.',
              'طلب الحذف في الحالات المنصوص عليها قانونًا.',
              'الاعتراض على بعض المعالجات أو تقييدها.',
              'سحب الموافقات الاختيارية دون التأثير على قانونية المعالجة السابقة للسحب.',
            ]),

            _SectionTitle('10) ملفات تعريف الارتباط (Cookies)'),
            _SectionBody(
              'نستخدم الكوكيز وتقنيات مشابهة لتشغيل الميزات الأساسية وتحسين الأداء وقياس الاستخدام. '
                  'يمكنك إدارة التفضيلات من إعدادات الجهاز/المتصفح. قد يؤثر التعطيل على بعض وظائف التطبيق.',
            ),

            _SectionTitle('11) نقل البيانات عبر الحدود'),
            _SectionBody(
              'قد تُعالَج بياناتك على خوادم خارج بلدك مع ضمان توفير مستويات حماية مناسبة ووسائل تعاقدية سليمة.',
            ),

            _SectionTitle('12) الأطفال'),
            _SectionBody(
              'لا يستهدف التطبيق من هم دون السن القانوني. في حال علمنا بجمع بيانات دون موافقة صحيحة، سنقوم بحذفها.',
            ),

            _SectionTitle('13) التحديثات'),
            _SectionBody(
              'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. يسري أي تعديل من تاريخ نشره داخل التطبيق.',
            ),

            _SectionTitle('14) التواصل معنا'),
            _Bullets(items: const [
              'من داخل التطبيق: قسم “تواصل معنا”.',
              'عبر قنوات الاتصال المُعلنة ضمن صفحة الشركة.',
            ]),

            const SizedBox(height: 18),
            ShamraButton(
              text: 'تم الفهم',
              onPressed: () => Get.back(),
              isSecondary: true,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- UI helpers (reuse from terms file) ----------
class _LegalHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String lastUpdated;
  const _LegalHeader({required this.title, required this.subtitle, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.3)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 6),
          Text(lastUpdated, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;
  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: const TextStyle(fontSize: 14.5, height: 1.8, color: AppColors.textSecondary),
    );
  }
}

class _Bullets extends StatelessWidget {
  final List<String> items;
  const _Bullets({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (e) => Padding(
          padding: const EdgeInsetsDirectional.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: TextStyle(fontSize: 16, height: 1.6, color: AppColors.textPrimary)),
              Expanded(
                child: Text(
                  e,
                  style: const TextStyle(fontSize: 14.5, height: 1.8, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}
