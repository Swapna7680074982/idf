import '../models/meta_models.dart';
import '../services/metadata_service.dart';

/// Complete list of countries and phone codes provided by backend.
const List<Country> kAllCountries = [
  Country(id: 8, isoCode: 'AF', name: 'Afghanistan', phoneCode: '+93'),
  Country(id: 9, isoCode: 'AX', name: 'Aland Islands', phoneCode: '+35818'),
  Country(id: 10, isoCode: 'AL', name: 'Albania', phoneCode: '+355'),
  Country(id: 11, isoCode: 'DZ', name: 'Algeria', phoneCode: '+213'),
  Country(id: 12, isoCode: 'AS', name: 'American Samoa', phoneCode: '+1684'),
  Country(id: 13, isoCode: 'AD', name: 'Andorra', phoneCode: '+376'),
  Country(id: 14, isoCode: 'AO', name: 'Angola', phoneCode: '+244'),
  Country(id: 15, isoCode: 'AI', name: 'Anguilla', phoneCode: '+1264'),
  Country(id: 16, isoCode: 'AQ', name: 'Antarctica', phoneCode: '+672'),
  Country(id: 17, isoCode: 'AG', name: 'Antigua And Barbuda', phoneCode: '+1268'),
  Country(id: 18, isoCode: 'AR', name: 'Argentina', phoneCode: '+54'),
  Country(id: 19, isoCode: 'AM', name: 'Armenia', phoneCode: '+374'),
  Country(id: 20, isoCode: 'AW', name: 'Aruba', phoneCode: '+297'),
  Country(id: 21, isoCode: 'AU', name: 'Australia', phoneCode: '+61'),
  Country(id: 22, isoCode: 'AT', name: 'Austria', phoneCode: '+43'),
  Country(id: 23, isoCode: 'AZ', name: 'Azerbaijan', phoneCode: '+994'),
  Country(id: 25, isoCode: 'BH', name: 'Bahrain', phoneCode: '+973'),
  Country(id: 26, isoCode: 'BD', name: 'Bangladesh', phoneCode: '+880'),
  Country(id: 27, isoCode: 'BB', name: 'Barbados', phoneCode: '+1246'),
  Country(id: 28, isoCode: 'BY', name: 'Belarus', phoneCode: '+375'),
  Country(id: 29, isoCode: 'BE', name: 'Belgium', phoneCode: '+32'),
  Country(id: 30, isoCode: 'BZ', name: 'Belize', phoneCode: '+501'),
  Country(id: 31, isoCode: 'BJ', name: 'Benin', phoneCode: '+229'),
  Country(id: 32, isoCode: 'BM', name: 'Bermuda', phoneCode: '+1441'),
  Country(id: 33, isoCode: 'BT', name: 'Bhutan', phoneCode: '+975'),
  Country(id: 34, isoCode: 'BO', name: 'Bolivia', phoneCode: '+591'),
  Country(id: 160, isoCode: 'BQ', name: 'Bonaire, Sint Eustatius and Saba', phoneCode: '+599'),
  Country(id: 35, isoCode: 'BA', name: 'Bosnia and Herzegovina', phoneCode: '+387'),
  Country(id: 36, isoCode: 'BW', name: 'Botswana', phoneCode: '+267'),
  Country(id: 37, isoCode: 'BV', name: 'Bouvet Island', phoneCode: '+0055'),
  Country(id: 38, isoCode: 'BR', name: 'Brazil', phoneCode: '+55'),
  Country(id: 39, isoCode: 'IO', name: 'British Indian Ocean Territory', phoneCode: '+246'),
  Country(id: 40, isoCode: 'BN', name: 'Brunei', phoneCode: '+673'),
  Country(id: 41, isoCode: 'BG', name: 'Bulgaria', phoneCode: '+359'),
  Country(id: 42, isoCode: 'BF', name: 'Burkina Faso', phoneCode: '+226'),
  Country(id: 43, isoCode: 'BI', name: 'Burundi', phoneCode: '+257'),
  Country(id: 44, isoCode: 'KH', name: 'Cambodia', phoneCode: '+855'),
  Country(id: 45, isoCode: 'CM', name: 'Cameroon', phoneCode: '+237'),
  Country(id: 46, isoCode: 'CA', name: 'Canada', phoneCode: '+1'),
  Country(id: 47, isoCode: 'CV', name: 'Cape Verde', phoneCode: '+238'),
  Country(id: 48, isoCode: 'KY', name: 'Cayman Islands', phoneCode: '+1345'),
  Country(id: 49, isoCode: 'CF', name: 'Central African Republic', phoneCode: '+236'),
  Country(id: 50, isoCode: 'TD', name: 'Chad', phoneCode: '+235'),
  Country(id: 51, isoCode: 'CL', name: 'Chile', phoneCode: '+56'),
  Country(id: 52, isoCode: 'CN', name: 'China', phoneCode: '+86'),
  Country(id: 53, isoCode: 'CX', name: 'Christmas Island', phoneCode: '+61'),
  Country(id: 54, isoCode: 'CC', name: 'Cocos (Keeling) Islands', phoneCode: '+61'),
  Country(id: 55, isoCode: 'CO', name: 'Colombia', phoneCode: '+57'),
  Country(id: 56, isoCode: 'KM', name: 'Comoros', phoneCode: '+269'),
  Country(id: 57, isoCode: 'CG', name: 'Congo', phoneCode: '+242'),
  Country(id: 59, isoCode: 'CK', name: 'Cook Islands', phoneCode: '+682'),
  Country(id: 60, isoCode: 'CR', name: 'Costa Rica', phoneCode: '+506'),
  Country(id: 61, isoCode: 'CI', name: "Cote D'Ivoire (Ivory Coast)", phoneCode: '+225'),
  Country(id: 62, isoCode: 'HR', name: 'Croatia', phoneCode: '+385'),
  Country(id: 63, isoCode: 'CU', name: 'Cuba', phoneCode: '+53'),
  Country(id: 251, isoCode: 'CW', name: 'Curaçao', phoneCode: '+599'),
  Country(id: 64, isoCode: 'CY', name: 'Cyprus', phoneCode: '+357'),
  Country(id: 65, isoCode: 'CZ', name: 'Czech Republic', phoneCode: '+420'),
  Country(id: 58, isoCode: 'CD', name: 'Democratic Republic of the Congo', phoneCode: '+243'),
  Country(id: 66, isoCode: 'DK', name: 'Denmark', phoneCode: '+45'),
  Country(id: 67, isoCode: 'DJ', name: 'Djibouti', phoneCode: '+253'),
  Country(id: 68, isoCode: 'DM', name: 'Dominica', phoneCode: '+1767'),
  Country(id: 69, isoCode: 'DO', name: 'Dominican Republic', phoneCode: '+1809'),
  Country(id: 70, isoCode: 'TL', name: 'East Timor', phoneCode: '+670'),
  Country(id: 71, isoCode: 'EC', name: 'Ecuador', phoneCode: '+593'),
  Country(id: 72, isoCode: 'EG', name: 'Egypt', phoneCode: '+20'),
  Country(id: 73, isoCode: 'SV', name: 'El Salvador', phoneCode: '+503'),
  Country(id: 74, isoCode: 'GQ', name: 'Equatorial Guinea', phoneCode: '+240'),
  Country(id: 75, isoCode: 'ER', name: 'Eritrea', phoneCode: '+291'),
  Country(id: 76, isoCode: 'EE', name: 'Estonia', phoneCode: '+372'),
  Country(id: 77, isoCode: 'ET', name: 'Ethiopia', phoneCode: '+251'),
  Country(id: 78, isoCode: 'FK', name: 'Falkland Islands', phoneCode: '+500'),
  Country(id: 79, isoCode: 'FO', name: 'Faroe Islands', phoneCode: '+298'),
  Country(id: 80, isoCode: 'FJ', name: 'Fiji Islands', phoneCode: '+679'),
  Country(id: 81, isoCode: 'FI', name: 'Finland', phoneCode: '+358'),
  Country(id: 82, isoCode: 'FR', name: 'France', phoneCode: '+33'),
  Country(id: 83, isoCode: 'GF', name: 'French Guiana', phoneCode: '+594'),
  Country(id: 84, isoCode: 'PF', name: 'French Polynesia', phoneCode: '+689'),
  Country(id: 85, isoCode: 'TF', name: 'French Southern Territories', phoneCode: '+262'),
  Country(id: 86, isoCode: 'GA', name: 'Gabon', phoneCode: '+241'),
  Country(id: 88, isoCode: 'GE', name: 'Georgia', phoneCode: '+995'),
  Country(id: 89, isoCode: 'DE', name: 'Germany', phoneCode: '+49'),
  Country(id: 90, isoCode: 'GH', name: 'Ghana', phoneCode: '+233'),
  Country(id: 91, isoCode: 'GI', name: 'Gibraltar', phoneCode: '+350'),
  Country(id: 92, isoCode: 'GR', name: 'Greece', phoneCode: '+30'),
  Country(id: 93, isoCode: 'GL', name: 'Greenland', phoneCode: '+299'),
  Country(id: 94, isoCode: 'GD', name: 'Grenada', phoneCode: '+1473'),
  Country(id: 95, isoCode: 'GP', name: 'Guadeloupe', phoneCode: '+590'),
  Country(id: 96, isoCode: 'GU', name: 'Guam', phoneCode: '+1671'),
  Country(id: 97, isoCode: 'GT', name: 'Guatemala', phoneCode: '+502'),
  Country(id: 98, isoCode: 'GG', name: 'Guernsey and Alderney', phoneCode: '+441481'),
  Country(id: 99, isoCode: 'GN', name: 'Guinea', phoneCode: '+224'),
  Country(id: 100, isoCode: 'GW', name: 'Guinea-Bissau', phoneCode: '+245'),
  Country(id: 101, isoCode: 'GY', name: 'Guyana', phoneCode: '+592'),
  Country(id: 102, isoCode: 'HT', name: 'Haiti', phoneCode: '+509'),
  Country(id: 103, isoCode: 'HM', name: 'Heard Island and McDonald Islands', phoneCode: '+672'),
  Country(id: 104, isoCode: 'HN', name: 'Honduras', phoneCode: '+504'),
  Country(id: 105, isoCode: 'HK', name: 'Hong Kong S.A.R.', phoneCode: '+852'),
  Country(id: 106, isoCode: 'HU', name: 'Hungary', phoneCode: '+36'),
  Country(id: 107, isoCode: 'IS', name: 'Iceland', phoneCode: '+354'),
  Country(id: 1, isoCode: 'IN', name: 'India', phoneCode: '+91'),
  Country(id: 108, isoCode: 'ID', name: 'Indonesia', phoneCode: '+62'),
  Country(id: 109, isoCode: 'IR', name: 'Iran', phoneCode: '+98'),
  Country(id: 110, isoCode: 'IQ', name: 'Iraq', phoneCode: '+964'),
  Country(id: 111, isoCode: 'IE', name: 'Ireland', phoneCode: '+353'),
  Country(id: 112, isoCode: 'IL', name: 'Israel', phoneCode: '+972'),
  Country(id: 113, isoCode: 'IT', name: 'Italy', phoneCode: '+39'),
  Country(id: 114, isoCode: 'JM', name: 'Jamaica', phoneCode: '+1876'),
  Country(id: 115, isoCode: 'JP', name: 'Japan', phoneCode: '+81'),
  Country(id: 116, isoCode: 'JE', name: 'Jersey', phoneCode: '+441534'),
  Country(id: 117, isoCode: 'JO', name: 'Jordan', phoneCode: '+962'),
  Country(id: 118, isoCode: 'KZ', name: 'Kazakhstan', phoneCode: '+7'),
  Country(id: 2, isoCode: 'KE', name: 'Kenya', phoneCode: '+254'),
  Country(id: 119, isoCode: 'KI', name: 'Kiribati', phoneCode: '+686'),
  Country(id: 250, isoCode: 'XK', name: 'Kosovo', phoneCode: '+383'),
  Country(id: 122, isoCode: 'KW', name: 'Kuwait', phoneCode: '+965'),
  Country(id: 123, isoCode: 'KG', name: 'Kyrgyzstan', phoneCode: '+996'),
  Country(id: 124, isoCode: 'LA', name: 'Laos', phoneCode: '+856'),
  Country(id: 125, isoCode: 'LV', name: 'Latvia', phoneCode: '+371'),
  Country(id: 126, isoCode: 'LB', name: 'Lebanon', phoneCode: '+961'),
  Country(id: 127, isoCode: 'LS', name: 'Lesotho', phoneCode: '+266'),
  Country(id: 128, isoCode: 'LR', name: 'Liberia', phoneCode: '+231'),
  Country(id: 129, isoCode: 'LY', name: 'Libya', phoneCode: '+218'),
  Country(id: 130, isoCode: 'LI', name: 'Liechtenstein', phoneCode: '+423'),
  Country(id: 131, isoCode: 'LT', name: 'Lithuania', phoneCode: '+370'),
  Country(id: 132, isoCode: 'LU', name: 'Luxembourg', phoneCode: '+352'),
  Country(id: 133, isoCode: 'MO', name: 'Macau S.A.R.', phoneCode: '+853'),
  Country(id: 134, isoCode: 'MK', name: 'Macedonia', phoneCode: '+389'),
  Country(id: 135, isoCode: 'MG', name: 'Madagascar', phoneCode: '+261'),
  Country(id: 136, isoCode: 'MW', name: 'Malawi', phoneCode: '+265'),
  Country(id: 137, isoCode: 'MY', name: 'Malaysia', phoneCode: '+60'),
  Country(id: 138, isoCode: 'MV', name: 'Maldives', phoneCode: '+960'),
  Country(id: 139, isoCode: 'ML', name: 'Mali', phoneCode: '+223'),
  Country(id: 140, isoCode: 'MT', name: 'Malta', phoneCode: '+356'),
  Country(id: 141, isoCode: 'IM', name: 'Man (Isle of)', phoneCode: '+441624'),
  Country(id: 142, isoCode: 'MH', name: 'Marshall Islands', phoneCode: '+692'),
  Country(id: 143, isoCode: 'MQ', name: 'Martinique', phoneCode: '+596'),
  Country(id: 144, isoCode: 'MR', name: 'Mauritania', phoneCode: '+222'),
  Country(id: 145, isoCode: 'MU', name: 'Mauritius', phoneCode: '+230'),
  Country(id: 146, isoCode: 'YT', name: 'Mayotte', phoneCode: '+262'),
  Country(id: 147, isoCode: 'MX', name: 'Mexico', phoneCode: '+52'),
  Country(id: 148, isoCode: 'FM', name: 'Micronesia', phoneCode: '+691'),
  Country(id: 149, isoCode: 'MD', name: 'Moldova', phoneCode: '+373'),
  Country(id: 150, isoCode: 'MC', name: 'Monaco', phoneCode: '+377'),
  Country(id: 151, isoCode: 'MN', name: 'Mongolia', phoneCode: '+976'),
  Country(id: 152, isoCode: 'ME', name: 'Montenegro', phoneCode: '+382'),
  Country(id: 153, isoCode: 'MS', name: 'Montserrat', phoneCode: '+1664'),
  Country(id: 154, isoCode: 'MA', name: 'Morocco', phoneCode: '+212'),
  Country(id: 155, isoCode: 'MZ', name: 'Mozambique', phoneCode: '+258'),
  Country(id: 156, isoCode: 'MM', name: 'Myanmar', phoneCode: '+95'),
  Country(id: 157, isoCode: 'NA', name: 'Namibia', phoneCode: '+264'),
  Country(id: 158, isoCode: 'NR', name: 'Nauru', phoneCode: '+674'),
  Country(id: 159, isoCode: 'NP', name: 'Nepal', phoneCode: '+977'),
  Country(id: 161, isoCode: 'NL', name: 'Netherlands', phoneCode: '+31'),
  Country(id: 162, isoCode: 'NC', name: 'New Caledonia', phoneCode: '+687'),
  Country(id: 163, isoCode: 'NZ', name: 'New Zealand', phoneCode: '+64'),
  Country(id: 164, isoCode: 'NI', name: 'Nicaragua', phoneCode: '+505'),
  Country(id: 165, isoCode: 'NE', name: 'Niger', phoneCode: '+227'),
  Country(id: 3, isoCode: 'NG', name: 'Nigeria', phoneCode: '+234'),
  Country(id: 166, isoCode: 'NU', name: 'Niue', phoneCode: '+683'),
  Country(id: 167, isoCode: 'NF', name: 'Norfolk Island', phoneCode: '+672'),
  Country(id: 120, isoCode: 'KP', name: 'North Korea', phoneCode: '+850'),
  Country(id: 168, isoCode: 'MP', name: 'Northern Mariana Islands', phoneCode: '+1670'),
  Country(id: 169, isoCode: 'NO', name: 'Norway', phoneCode: '+47'),
  Country(id: 170, isoCode: 'OM', name: 'Oman', phoneCode: '+968'),
  Country(id: 171, isoCode: 'PK', name: 'Pakistan', phoneCode: '+92'),
  Country(id: 172, isoCode: 'PW', name: 'Palau', phoneCode: '+680'),
  Country(id: 173, isoCode: 'PS', name: 'Palestinian Territory Occupied', phoneCode: '+970'),
  Country(id: 174, isoCode: 'PA', name: 'Panama', phoneCode: '+507'),
  Country(id: 175, isoCode: 'PG', name: 'Papua new Guinea', phoneCode: '+675'),
  Country(id: 176, isoCode: 'PY', name: 'Paraguay', phoneCode: '+595'),
  Country(id: 177, isoCode: 'PE', name: 'Peru', phoneCode: '+51'),
  Country(id: 178, isoCode: 'PH', name: 'Philippines', phoneCode: '+63'),
  Country(id: 179, isoCode: 'PN', name: 'Pitcairn Island', phoneCode: '+870'),
  Country(id: 180, isoCode: 'PL', name: 'Poland', phoneCode: '+48'),
  Country(id: 181, isoCode: 'PT', name: 'Portugal', phoneCode: '+351'),
  Country(id: 182, isoCode: 'PR', name: 'Puerto Rico', phoneCode: '+1787'),
  Country(id: 183, isoCode: 'QA', name: 'Qatar', phoneCode: '+974'),
  Country(id: 184, isoCode: 'RE', name: 'Reunion', phoneCode: '+262'),
  Country(id: 185, isoCode: 'RO', name: 'Romania', phoneCode: '+40'),
  Country(id: 186, isoCode: 'RU', name: 'Russia', phoneCode: '+7'),
  Country(id: 187, isoCode: 'RW', name: 'Rwanda', phoneCode: '+250'),
  Country(id: 188, isoCode: 'SH', name: 'Saint Helena', phoneCode: '+290'),
  Country(id: 189, isoCode: 'KN', name: 'Saint Kitts And Nevis', phoneCode: '+1869'),
  Country(id: 190, isoCode: 'LC', name: 'Saint Lucia', phoneCode: '+1758'),
  Country(id: 191, isoCode: 'PM', name: 'Saint Pierre and Miquelon', phoneCode: '+508'),
  Country(id: 192, isoCode: 'VC', name: 'Saint Vincent And The Grenadines', phoneCode: '+1784'),
  Country(id: 193, isoCode: 'BL', name: 'Saint-Barthelemy', phoneCode: '+590'),
  Country(id: 194, isoCode: 'MF', name: 'Saint-Martin (French part)', phoneCode: '+590'),
  Country(id: 195, isoCode: 'WS', name: 'Samoa', phoneCode: '+685'),
  Country(id: 196, isoCode: 'SM', name: 'San Marino', phoneCode: '+378'),
  Country(id: 197, isoCode: 'ST', name: 'Sao Tome and Principe', phoneCode: '+239'),
  Country(id: 198, isoCode: 'SA', name: 'Saudi Arabia', phoneCode: '+966'),
  Country(id: 199, isoCode: 'SN', name: 'Senegal', phoneCode: '+221'),
  Country(id: 200, isoCode: 'RS', name: 'Serbia', phoneCode: '+381'),
  Country(id: 201, isoCode: 'SC', name: 'Seychelles', phoneCode: '+248'),
  Country(id: 202, isoCode: 'SL', name: 'Sierra Leone', phoneCode: '+232'),
  Country(id: 203, isoCode: 'SG', name: 'Singapore', phoneCode: '+65'),
  Country(id: 252, isoCode: 'SX', name: 'Sint Maarten (Dutch part)', phoneCode: '+1721'),
  Country(id: 204, isoCode: 'SK', name: 'Slovakia', phoneCode: '+421'),
  Country(id: 205, isoCode: 'SI', name: 'Slovenia', phoneCode: '+386'),
  Country(id: 206, isoCode: 'SB', name: 'Solomon Islands', phoneCode: '+677'),
  Country(id: 207, isoCode: 'SO', name: 'Somalia', phoneCode: '+252'),
  Country(id: 208, isoCode: 'ZA', name: 'South Africa', phoneCode: '+27'),
  Country(id: 209, isoCode: 'GS', name: 'South Georgia', phoneCode: '+500'),
  Country(id: 121, isoCode: 'KR', name: 'South Korea', phoneCode: '+82'),
  Country(id: 210, isoCode: 'SS', name: 'South Sudan', phoneCode: '+211'),
  Country(id: 211, isoCode: 'ES', name: 'Spain', phoneCode: '+34'),
  Country(id: 212, isoCode: 'LK', name: 'Sri Lanka', phoneCode: '+94'),
  Country(id: 213, isoCode: 'SD', name: 'Sudan', phoneCode: '+249'),
  Country(id: 214, isoCode: 'SR', name: 'Suriname', phoneCode: '+597'),
  Country(id: 215, isoCode: 'SJ', name: 'Svalbard And Jan Mayen Islands', phoneCode: '+47'),
  Country(id: 216, isoCode: 'SZ', name: 'Swaziland', phoneCode: '+268'),
  Country(id: 217, isoCode: 'SE', name: 'Sweden', phoneCode: '+46'),
  Country(id: 218, isoCode: 'CH', name: 'Switzerland', phoneCode: '+41'),
  Country(id: 219, isoCode: 'SY', name: 'Syria', phoneCode: '+963'),
  Country(id: 220, isoCode: 'TW', name: 'Taiwan', phoneCode: '+886'),
  Country(id: 221, isoCode: 'TJ', name: 'Tajikistan', phoneCode: '+992'),
  Country(id: 222, isoCode: 'TZ', name: 'Tanzania', phoneCode: '+255'),
  Country(id: 4, isoCode: 'TH', name: 'Thailand', phoneCode: '+66'),
  Country(id: 24, isoCode: 'BS', name: 'The Bahamas', phoneCode: '+1242'),
  Country(id: 87, isoCode: 'GM', name: 'The Gambia', phoneCode: '+220'),
  Country(id: 223, isoCode: 'TG', name: 'Togo', phoneCode: '+228'),
  Country(id: 224, isoCode: 'TK', name: 'Tokelau', phoneCode: '+690'),
  Country(id: 225, isoCode: 'TO', name: 'Tonga', phoneCode: '+676'),
  Country(id: 226, isoCode: 'TT', name: 'Trinidad And Tobago', phoneCode: '+1868'),
  Country(id: 227, isoCode: 'TN', name: 'Tunisia', phoneCode: '+216'),
  Country(id: 228, isoCode: 'TR', name: 'Turkey', phoneCode: '+90'),
  Country(id: 229, isoCode: 'TM', name: 'Turkmenistan', phoneCode: '+993'),
  Country(id: 230, isoCode: 'TC', name: 'Turks And Caicos Islands', phoneCode: '+1649'),
  Country(id: 231, isoCode: 'TV', name: 'Tuvalu', phoneCode: '+688'),
  Country(id: 232, isoCode: 'UG', name: 'Uganda', phoneCode: '+256'),
  Country(id: 233, isoCode: 'UA', name: 'Ukraine', phoneCode: '+380'),
  Country(id: 234, isoCode: 'AE', name: 'United Arab Emirates', phoneCode: '+971'),
  Country(id: 235, isoCode: 'GB', name: 'United Kingdom', phoneCode: '+44'),
  Country(id: 5, isoCode: 'US', name: 'United States', phoneCode: '+1'),
  Country(id: 236, isoCode: 'UM', name: 'United States Minor Outlying Islands', phoneCode: '+1'),
  Country(id: 237, isoCode: 'UY', name: 'Uruguay', phoneCode: '+598'),
  Country(id: 238, isoCode: 'UZ', name: 'Uzbekistan', phoneCode: '+998'),
  Country(id: 239, isoCode: 'VU', name: 'Vanuatu', phoneCode: '+678'),
  Country(id: 240, isoCode: 'VA', name: 'Vatican City State (Holy See)', phoneCode: '+379'),
  Country(id: 241, isoCode: 'VE', name: 'Venezuela', phoneCode: '+58'),
  Country(id: 242, isoCode: 'VN', name: 'Vietnam', phoneCode: '+84'),
  Country(id: 243, isoCode: 'VG', name: 'Virgin Islands (British)', phoneCode: '+1284'),
  Country(id: 244, isoCode: 'VI', name: 'Virgin Islands (US)', phoneCode: '+1340'),
  Country(id: 245, isoCode: 'WF', name: 'Wallis And Futuna Islands', phoneCode: '+681'),
  Country(id: 246, isoCode: 'EH', name: 'Western Sahara', phoneCode: '+212'),
  Country(id: 247, isoCode: 'YE', name: 'Yemen', phoneCode: '+967'),
  Country(id: 248, isoCode: 'ZM', name: 'Zambia', phoneCode: '+260'),
  Country(id: 249, isoCode: 'ZW', name: 'Zimbabwe', phoneCode: '+263'),
];

/// Helper methods to look up countries.
class CountryData {
  static const Country defaultCountry = Country(
    id: 1,
    isoCode: 'IN',
    name: 'India',
    phoneCode: '+91',
  );

  /// Fallback / Safety "Other" option if country code is unlisted
  static const Country otherCountry = Country(
    id: 0,
    isoCode: 'OT',
    name: 'Other',
    phoneCode: '+',
  );

  static List<Country>? _cachedDynamicCountries;

  /// Loads countries dynamically from backend API (/api/meta/countries)
  static Future<List<Country>> fetchDynamicCountries({bool forceRefresh = false}) async {
    if (_cachedDynamicCountries != null && _cachedDynamicCountries!.isNotEmpty && !forceRefresh) {
      return _cachedDynamicCountries!;
    }
    try {
      final list = await MetadataService.getCountries();
      if (list.isNotEmpty) {
        _cachedDynamicCountries = list;
        return list;
      }
    } catch (_) {}
    return kAllCountries;
  }

  /// Returns currently available countries (dynamic from backend if loaded, otherwise fallback list)
  static List<Country> get currentCountries =>
      (_cachedDynamicCountries != null && _cachedDynamicCountries!.isNotEmpty)
          ? _cachedDynamicCountries!
          : kAllCountries;

  /// Find country by phone dial code (e.g. '+91' or '91')
  static Country findByPhoneCode(String? code, {Country? fallback}) {
    if (code == null || code.trim().isEmpty) {
      return fallback ?? defaultCountry;
    }
    final clean = code.trim().startsWith('+') ? code.trim() : '+${code.trim()}';
    if (clean == '+' || clean.toLowerCase() == 'other') {
      return otherCountry;
    }
    try {
      return currentCountries.firstWhere(
        (c) => c.phoneCode == clean,
        orElse: () => fallback ?? defaultCountry,
      );
    } catch (_) {
      return fallback ?? defaultCountry;
    }
  }

  /// Find country by ISO code (e.g. 'IN', 'US')
  static Country findByIsoCode(String? isoCode, {Country? fallback}) {
    if (isoCode == null || isoCode.trim().isEmpty) {
      return fallback ?? defaultCountry;
    }
    final clean = isoCode.trim().toUpperCase();
    if (clean == 'OT' || clean == 'OTHER') {
      return otherCountry;
    }
    try {
      return currentCountries.firstWhere(
        (c) => c.isoCode.toUpperCase() == clean,
        orElse: () => fallback ?? defaultCountry,
      );
    } catch (_) {
      return fallback ?? defaultCountry;
    }
  }

  /// Find country by ID
  static Country findById(int? id, {Country? fallback}) {
    if (id == null) return fallback ?? defaultCountry;
    if (id == 0) return otherCountry;
    try {
      return currentCountries.firstWhere(
        (c) => c.id == id,
        orElse: () => fallback ?? defaultCountry,
      );
    } catch (_) {
      return fallback ?? defaultCountry;
    }
  }

  static const Map<String, CountryPhoneRule> _phoneRules = {
    // Asia & Middle East
    'IN': CountryPhoneRule(minLength: 10, maxLength: 10, example: '9876543210'),
    'PK': CountryPhoneRule(minLength: 10, maxLength: 10, example: '3001234567'),
    'BD': CountryPhoneRule(minLength: 10, maxLength: 10, example: '1712345678'),
    'LK': CountryPhoneRule(minLength: 9, maxLength: 9, example: '712345678'),
    'NP': CountryPhoneRule(minLength: 10, maxLength: 10, example: '9841234567'),
    'AE': CountryPhoneRule(minLength: 9, maxLength: 9, example: '501234567'),
    'SA': CountryPhoneRule(minLength: 9, maxLength: 9, example: '512345678'),
    'QA': CountryPhoneRule(minLength: 8, maxLength: 8, example: '33123456'),
    'KW': CountryPhoneRule(minLength: 8, maxLength: 8, example: '91234567'),
    'BH': CountryPhoneRule(minLength: 8, maxLength: 8, example: '36123456'),
    'OM': CountryPhoneRule(minLength: 8, maxLength: 8, example: '91234567'),
    'SG': CountryPhoneRule(minLength: 8, maxLength: 8, example: '81234567'),
    'MY': CountryPhoneRule(minLength: 9, maxLength: 10, example: '123456789'),
    'ID': CountryPhoneRule(minLength: 9, maxLength: 12, example: '81234567890'),
    'PH': CountryPhoneRule(minLength: 10, maxLength: 10, example: '9171234567'),
    'TH': CountryPhoneRule(minLength: 9, maxLength: 9, example: '812345678'),
    'VN': CountryPhoneRule(minLength: 9, maxLength: 10, example: '912345678'),
    'JP': CountryPhoneRule(minLength: 10, maxLength: 10, example: '9012345678'),
    'KR': CountryPhoneRule(minLength: 9, maxLength: 10, example: '1012345678'),
    'CN': CountryPhoneRule(minLength: 11, maxLength: 11, example: '13800138000'),
    'HK': CountryPhoneRule(minLength: 8, maxLength: 8, example: '91234567'),
    'TW': CountryPhoneRule(minLength: 9, maxLength: 9, example: '912345678'),
    'IL': CountryPhoneRule(minLength: 9, maxLength: 9, example: '501234567'),
    'JO': CountryPhoneRule(minLength: 9, maxLength: 9, example: '791234567'),
    'LB': CountryPhoneRule(minLength: 7, maxLength: 8, example: '71123456'),
    'TR': CountryPhoneRule(minLength: 10, maxLength: 10, example: '5321234567'),

    // Americas
    'US': CountryPhoneRule(minLength: 10, maxLength: 10, example: '2025550143'),
    'CA': CountryPhoneRule(minLength: 10, maxLength: 10, example: '4165550143'),
    'MX': CountryPhoneRule(minLength: 10, maxLength: 10, example: '5512345678'),
    'BR': CountryPhoneRule(minLength: 10, maxLength: 11, example: '11987654321'),
    'AR': CountryPhoneRule(minLength: 10, maxLength: 10, example: '91123456789'),
    'CL': CountryPhoneRule(minLength: 9, maxLength: 9, example: '912345678'),
    'CO': CountryPhoneRule(minLength: 10, maxLength: 10, example: '3001234567'),
    'PE': CountryPhoneRule(minLength: 9, maxLength: 9, example: '912345678'),

    // Europe
    'GB': CountryPhoneRule(minLength: 10, maxLength: 10, example: '7911123456'),
    'DE': CountryPhoneRule(minLength: 10, maxLength: 11, example: '15123456789'),
    'FR': CountryPhoneRule(minLength: 9, maxLength: 9, example: '612345678'),
    'IT': CountryPhoneRule(minLength: 9, maxLength: 10, example: '3123456789'),
    'ES': CountryPhoneRule(minLength: 9, maxLength: 9, example: '612345678'),
    'NL': CountryPhoneRule(minLength: 9, maxLength: 9, example: '612345678'),
    'CH': CountryPhoneRule(minLength: 9, maxLength: 9, example: '781234567'),
    'SE': CountryPhoneRule(minLength: 9, maxLength: 10, example: '701234567'),
    'NO': CountryPhoneRule(minLength: 8, maxLength: 8, example: '41234567'),
    'DK': CountryPhoneRule(minLength: 8, maxLength: 8, example: '20123456'),
    'FI': CountryPhoneRule(minLength: 9, maxLength: 10, example: '401234567'),
    'PL': CountryPhoneRule(minLength: 9, maxLength: 9, example: '512345678'),
    'RU': CountryPhoneRule(minLength: 10, maxLength: 10, example: '9123456789'),
    'UA': CountryPhoneRule(minLength: 9, maxLength: 9, example: '501234567'),
    'IE': CountryPhoneRule(minLength: 9, maxLength: 9, example: '851234567'),
    'PT': CountryPhoneRule(minLength: 9, maxLength: 9, example: '912345678'),
    'GR': CountryPhoneRule(minLength: 10, maxLength: 10, example: '6912345678'),
    'AT': CountryPhoneRule(minLength: 9, maxLength: 11, example: '6641234567'),
    'BE': CountryPhoneRule(minLength: 9, maxLength: 9, example: '470123456'),

    // Africa & Oceania
    'KE': CountryPhoneRule(minLength: 9, maxLength: 9, example: '712345678'),
    'NG': CountryPhoneRule(minLength: 10, maxLength: 10, example: '8021234567'),
    'ZA': CountryPhoneRule(minLength: 9, maxLength: 9, example: '821234567'),
    'EG': CountryPhoneRule(minLength: 10, maxLength: 10, example: '1012345678'),
    'GH': CountryPhoneRule(minLength: 9, maxLength: 9, example: '241234567'),
    'TZ': CountryPhoneRule(minLength: 9, maxLength: 9, example: '712345678'),
    'UG': CountryPhoneRule(minLength: 9, maxLength: 9, example: '772123456'),
    'ET': CountryPhoneRule(minLength: 9, maxLength: 9, example: '911234567'),
    'AU': CountryPhoneRule(minLength: 9, maxLength: 9, example: '412345678'),
    'NZ': CountryPhoneRule(minLength: 8, maxLength: 10, example: '211234567'),

    // Other
    'OT': CountryPhoneRule(minLength: 4, maxLength: 15, example: '123456789'),
  };

  static const CountryPhoneRule defaultRule = CountryPhoneRule(
    minLength: 6,
    maxLength: 15,
    example: '123456789',
  );

  static CountryPhoneRule getPhoneRule(String? isoCode) {
    if (isoCode == null) return defaultRule;
    return _phoneRules[isoCode.toUpperCase()] ?? defaultRule;
  }

  /// Validates a phone number based on the selected country's rules
  static String? validatePhoneNumber({
    required Country? country,
    required String? phoneNumber,
    bool isRequired = true,
    String fieldName = 'phone number',
  }) {
    final text = phoneNumber?.trim() ?? '';
    if (text.isEmpty) {
      if (isRequired) return 'Please enter $fieldName';
      return null;
    }
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return 'Please enter digits only (0-9)';
    }
    final rule = getPhoneRule(country?.isoCode);
    final countryName = country?.name ?? 'selected country';
    if (country?.isoCode == 'OT') {
      if (text.length < rule.minLength) {
        return '$fieldName must be at least ${rule.minLength} digits';
      }
      if (text.length > rule.maxLength) {
        return '$fieldName cannot exceed ${rule.maxLength} digits';
      }
      return null;
    }
    if (rule.isExact) {
      if (text.length != rule.minLength) {
        return 'Please enter a valid ${rule.minLength}-digit $fieldName for $countryName';
      }
    } else {
      if (text.length < rule.minLength || text.length > rule.maxLength) {
        return '$fieldName for $countryName must be between ${rule.minLength} and ${rule.maxLength} digits';
      }
    }
    return null;
  }
}

/// Defines expected digits and sample for phone validation by country
class CountryPhoneRule {
  final int minLength;
  final int maxLength;
  final String example;

  const CountryPhoneRule({
    required this.minLength,
    required this.maxLength,
    required this.example,
  });

  bool get isExact => minLength == maxLength;
  String get lengthDescription =>
      isExact ? '$minLength digits' : '$minLength-$maxLength digits';
}
