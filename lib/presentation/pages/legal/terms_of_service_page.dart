// lib/presentation/pages/legal/terms_of_service_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/common_widgets.dart';

/// Terms of Service screen (Arabic content).
/// All comments are in English by request.
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    const companyName = 'شمرا';
    const lastUpdated = 'آخر تحديث: 21 أكتوبر 2025';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'شروط الخدمة'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _LegalHeader(title: 'شروط الخدمة', subtitle: '$companyName', lastUpdated: lastUpdated),

            _SectionTitle('1) الموافقة على الشروط'),
            _SectionBody(
              '$companyName يوفّر منصة/خدمات رقمية تساعدك على إدارة حسابك والاطلاع على منتجاتنا وخدماتنا وطلبها. '
                  'باستخدامك للتطبيق أو إنشاء حساب، فأنت تقرّ بقراءتك وفهمك لهذه الشروط وموافقتك عليها. '
                  'إذا لم توافق، يرجى التوقّف عن استخدام التطبيق.',
            ),

            _SectionTitle('2) التعاريف'),
            _Bullets(items: const [
              '“التطبيق/المنصة”: تطبيق شمرا وواجهاته وخدماته الرقمية.',
              '“المستخدم/أنت”: أي شخص طبيعي أو اعتباري يستخدم التطبيق.',
              '“الحساب”: ملف المستخدم المسجّل والمصادق عليه عبر رقم الهاتف/رمز التحقق.',
              '“الخدمات”: أي خدمات أو مزايا يقدّمها $companyName عبر التطبيق.',
            ]),

            _SectionTitle('3) الأهلية وإنشاء الحساب'),
            _Bullets(items: const [
              'يجب أن تكون ذا أهلية قانونية كاملة وفق القوانين النافذة.',
              'تلتزم بتقديم معلومات صحيحة ودقيقة ومحدّثة عند التسجيل.',
              'مسؤوليتك المحافظة على سرية بيانات الدخول وأي نشاط يتم عبر حسابك.',
            ]),

            _SectionTitle('4) الاستخدام المقبول'),
            _Bullets(items: const [
              'الامتناع عن أي استخدام مخالف للقانون، أو من شأنه الإضرار بـ $companyName أو المستخدمين.',
              'عدم محاولة التحايل على أنظمة الأمان أو الوصول غير المصرّح به.',
              'عدم نسخ أو إعادة بيع أو استغلال أي جزء من التطبيق خلافًا لما تسمح به هذه الشروط.',
            ]),

            _SectionTitle('5) المنتجات والأسعار والعروض'),
            _SectionBody(
              'قد يعرض $companyName منتجات وخدمات بعروض وأسعار متغيّرة من حين لآخر. '
                  'تبذل الشركة جهدًا معقولًا لضمان دقة المعلومات، دون ضمان خلوّها من الأخطاء بالكامل. '
                  'قد تُطبّق قيود التوفّر أو شروط إضافية تُعرض وقت الطلب.',
            ),

            _SectionTitle('6) الطلبات والدفع'),
            _Bullets(items: const [
              'يُعدّ إرسال الطلب عبر التطبيق عرضًا بالشراء ويُستكمل وفق التأكيد والدفع.',
              'قد نستخدم مزوّدين خارجيين للدفع؛ يخضع الدفع لشروطهم وسياساتهم.',
              'يجوز رفض أو إلغاء أي طلب وفق تقديرنا في حالات الاشتباه أو الأخطاء أو عدم التوفّر.',
            ]),

            _SectionTitle('7) التسليم/الاستلام والإرجاع'),
            _Bullets(items: const [
              'يتم تحديد آليات التسليم/الاستلام وفق المنطقة وسياسة الشركة.',
              'سياسة الإرجاع/الاستبدال (إن وُجدت) تُعرض داخل التطبيق أو مع الفاتورة.',
            ]),

            _SectionTitle('8) الملكية الفكرية'),
            _SectionBody(
              'جميع الحقوق والعلامات والشعارات والمحتوى المتاح على التطبيق تعود ملكيته لـ $companyName '
                  'أو المرخّصين له. لا يمنحك استخدام التطبيق أي حق في العلامات أو المحتوى إلا بترخيص صريح.',
            ),

            _SectionTitle('9) المحتوى الذي يقدّمه المستخدم'),
            _Bullets(items: const [
              'قد يتيح التطبيق تقييمات أو تعليقات؛ تتحمّل وحدك مسؤولية محتواك.',
              'تمنح $companyName ترخيصًا عالميًا غير حصري لاستخدام وعرض وتوزيع ذلك المحتوى بغرض تشغيل الخدمات وتطويرها.',
            ]),

            _SectionTitle('10) الاتصالات والإشعارات'),
            _SectionBody(
              'توافق على استلام رسائل SMS/واتساب/إشعارات دفع مرتبطة بالخدمة (رموز تحقق، تحديثات طلبات، عروض… إلخ). '
                  'يمكنك تعديل تفضيلات التسويق من الإعدادات متى توفّرت.',
            ),

            _SectionTitle('11) الضمانات وحدود المسؤولية'),
            _Bullets(items: const [
              'يُقدّم التطبيق “كما هو” و“حسب التوفّر” دون أي ضمانات صريحة أو ضمنية.',
              'لا يتحمّل $companyName أية مسؤولية عن أضرار غير مباشرة أو تبعية أو فقدان أرباح ناتجة عن الاستخدام.',
              'في جميع الأحوال، لا تتجاوز مسؤوليتنا الإجمالية (إن وُجدت) المبالغ التي دفعتها مقابل الخدمة المعنية خلال آخر 3 أشهر.',
            ]),

            _SectionTitle('12) مزوّدو الخدمات الخارجيون'),
            _SectionBody(
              'قد يتكامل التطبيق مع مزوّدين خارجيين (دفع، خرائط، شحن…). تخضع تعاملاتك معهم لشروطهم وسياساتهم الخاصة.',
            ),

            _SectionTitle('13) التعليق والإنهاء'),
            _SectionBody(
              'يجوز لـ $companyName تعليق أو إنهاء الوصول للحساب في أي وقت عند مخالفة الشروط أو لأسباب أمنية أو قانونية.',
            ),

            _SectionTitle('14) القانون والاختصاص القضائي'),
            _SectionBody(
              'تخضع هذه الشروط لقوانين الجمهورية العربية السورية ويختص القضاء السوري بالنظر في أي نزاع ينشأ عنها.',
            ),

            _SectionTitle('15) التعديلات على الشروط'),
            _SectionBody(
              'قد نقوم بتحديث هذه الشروط من وقت لآخر. يسري التحديث من تاريخ نشره داخل التطبيق. '
                  'استمرار استخدامك بعد النشر يُعدّ قبولًا للتعديلات.',
            ),

            _SectionTitle('16) التواصل معنا'),
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

// ---------- UI helpers (generic, reusable) ----------
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
