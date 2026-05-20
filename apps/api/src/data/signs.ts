export type SearchLang = "en" | "ne";

export interface SignRecord {
  id: string;
  conceptId: string;
  englishWord: string;
  nepaliWord: string;
  meaningEnglish: string;
  meaningNepali: string;
  category: string;
  /** Future CDN URL for the sign video (metadata only). */
  videoUrl: string | null;
}

const signRecords: SignRecord[] = [
  {
    id: "hello",
    conceptId: "concept-hello",
    englishWord: "Hello",
    nepaliWord: "नमस्ते",
    meaningEnglish: "A greeting used when meeting someone.",
    meaningNepali: "कसैलाई भेट्दा प्रयोग गरिने अभिवादन।",
    category: "Greetings",
    videoUrl: null,
  },
  {
    id: "thank-you",
    conceptId: "concept-thank-you",
    englishWord: "Thank you",
    nepaliWord: "धन्यवाद",
    meaningEnglish: "Expression of gratitude.",
    meaningNepali: "कृतज्ञता व्यक्त गर्ने शब्द।",
    category: "Greetings",
    videoUrl: null,
  },
  {
    id: "water",
    conceptId: "concept-water",
    englishWord: "Water",
    nepaliWord: "पानी",
    meaningEnglish: "Clear liquid essential for life.",
    meaningNepali: "जीवनको लागि आवश्यक पेय पदार्थ।",
    category: "Food & Drink",
    videoUrl: null,
  },
  {
    id: "rice",
    conceptId: "concept-rice",
    englishWord: "Rice",
    nepaliWord: "भात",
    meaningEnglish: "Staple grain eaten daily in Nepal.",
    meaningNepali: "नेपालमा दैनिक खाने मुख्य अन्न।",
    category: "Food & Drink",
    videoUrl: null,
  },
  {
    id: "mother",
    conceptId: "concept-mother",
    englishWord: "Mother",
    nepaliWord: "आमा",
    meaningEnglish: "A female parent.",
    meaningNepali: "महिला अभिभावक।",
    category: "Family",
    videoUrl: null,
  },
  {
    id: "father",
    conceptId: "concept-father",
    englishWord: "Father",
    nepaliWord: "बुबा",
    meaningEnglish: "A male parent.",
    meaningNepali: "पुरुष अभिभावक।",
    category: "Family",
    videoUrl: null,
  },
  {
    id: "school",
    conceptId: "concept-school",
    englishWord: "School",
    nepaliWord: "स्कूल",
    meaningEnglish: "A place where children learn.",
    meaningNepali: "बालबालिकाले पढ्ने ठाउँ।",
    category: "Education",
    videoUrl: null,
  },
  {
    id: "friend",
    conceptId: "concept-friend",
    englishWord: "Friend",
    nepaliWord: "साथी",
    meaningEnglish: "A person you know and like.",
    meaningNepali: "तपाईंले चिन्ने र मन पराउने व्यक्ति।",
    category: "People",
    videoUrl: null,
  },
];

export function parseSearchLang(
  languageInput: string | undefined,
): SearchLang | null {
  const normalizedLanguage = languageInput?.trim().toLowerCase();
  if (normalizedLanguage === "en" || normalizedLanguage === "english") {
    return "en";
  }
  if (normalizedLanguage === "ne" || normalizedLanguage === "nepali") {
    return "ne";
  }
  return null;
}

export function searchSigns(
  searchQuery: string,
  language: SearchLang,
): SignRecord[] {
  const normalizedQuery = searchQuery.trim().toLowerCase();
  if (!normalizedQuery) {
    return [];
  }

  return signRecords.filter((sign) => {
    const wordText =
      language === "en"
        ? sign.englishWord.toLowerCase()
        : sign.nepaliWord.toLowerCase();
    return wordText.includes(normalizedQuery);
  });
}

export function getSignById(signId: string): SignRecord | undefined {
  return signRecords.find((sign) => sign.id === signId);
}
