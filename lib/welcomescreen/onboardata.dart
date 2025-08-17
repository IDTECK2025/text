class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "സ്വർണ നിക്ഷേപം ₹1000 മുതൽ ₹10000 വരെ",
    image: "assets/images/image1 (1).png",
    desc: "നിങ്ങളുടെ സാധ്യതകൾക്ക് അനുയോജ്യമായി നിക്ഷേപം ആരംഭിക്കാം. 10 അല്ലെങ്കിൽ 12 മാസം വരെ tenor തിരഞ്ഞെടുക്കാം.",
  ),
  OnboardingContents(
    title: "പൂർത്തീകരണ ബോണസുകൾ നേടൂ",
    image: "assets/images/image2 (1).png",
    desc: "പദ്ധതി പൂർത്തിയാക്കിയാൽ 50 പോയിന്റുകൾ ലഭിക്കും. ഓരോ സമയത്തെയും കൃത്യമായ പേയ്‌മെന്റിനും 1 പോയിന്റ്.",
  ),
  OnboardingContents(
    title: "1 പോയിന്റ്  ₹10",
    image: "assets/images/image3 (1).png",
    desc: "പോയിന്റുകൾ redeem ചെയ്യാം! നിങ്ങളുടെ ഓരോ കൃത്യമായ പേയ്‌മെന്റിനും ₹10 വരെയുള്ള മൂല്യം നേടൂ.",
  ),
];
