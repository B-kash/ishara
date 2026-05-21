-- Seed data matching data/mock-signs.json
-- Applied by: npm run db:seed

insert into categories (id, name) values
  ('greetings', 'Greetings'),
  ('food-drink', 'Food & Drink'),
  ('family', 'Family'),
  ('education', 'Education'),
  ('people', 'People');

insert into concepts (id, category_id, meaning_english, meaning_nepali) values
  (
    'concept-hello',
    'greetings',
    'A greeting used when meeting someone.',
    'कसैलाई भेट्दा प्रयोग गरिने अभिवादन।'
  ),
  (
    'concept-thank-you',
    'greetings',
    'Expression of gratitude.',
    'कृतज्ञता व्यक्त गर्ने शब्द।'
  ),
  (
    'concept-water',
    'food-drink',
    'Clear liquid essential for life.',
    'जीवनको लागि आवश्यक पेय पदार्थ।'
  ),
  (
    'concept-rice',
    'food-drink',
    'Staple grain eaten daily in Nepal.',
    'नेपालमा दैनिक खाने मुख्य अन्न।'
  ),
  (
    'concept-mother',
    'family',
    'A female parent.',
    'महिला अभिभावक।'
  ),
  (
    'concept-father',
    'family',
    'A male parent.',
    'पुरुष अभिभावक।'
  ),
  (
    'concept-school',
    'education',
    'A place where children learn.',
    'बालबालिकाले पढ्ने ठाउँ।'
  ),
  (
    'concept-friend',
    'people',
    'A person you know and like.',
    'तपाईंले चिन्ने र मन पराउने व्यक्ति।'
  );

insert into words (concept_id, language, word) values
  ('concept-hello', 'en', 'hello'),
  ('concept-hello', 'ne', 'नमस्ते'),
  ('concept-thank-you', 'en', 'thank you'),
  ('concept-thank-you', 'ne', 'धन्यवाद'),
  ('concept-water', 'en', 'water'),
  ('concept-water', 'ne', 'पानी'),
  ('concept-rice', 'en', 'rice'),
  ('concept-rice', 'ne', 'भात'),
  ('concept-mother', 'en', 'mother'),
  ('concept-mother', 'ne', 'आमा'),
  ('concept-father', 'en', 'father'),
  ('concept-father', 'ne', 'बुबा'),
  ('concept-school', 'en', 'school'),
  ('concept-school', 'ne', 'स्कूल'),
  ('concept-friend', 'en', 'friend'),
  ('concept-friend', 'ne', 'साथी');

insert into signs (id, concept_id, video_url, thumbnail_url) values
  ('hello', 'concept-hello', null, null),
  ('thank-you', 'concept-thank-you', null, null),
  ('water', 'concept-water', null, null),
  ('rice', 'concept-rice', null, null),
  ('mother', 'concept-mother', null, null),
  ('father', 'concept-father', null, null),
  ('school', 'concept-school', null, null),
  ('friend', 'concept-friend', null, null);
