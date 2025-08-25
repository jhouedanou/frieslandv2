import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/support_service.dart';
import '../../core/services/planning_service.dart';
import '../../data/models/pdv_model.dart';
import '../../data/models/planning_visit_model.dart';
import '../widgets/planning_carousel.dart';
import 'visit_creation/visit_form_page.dart';

class HomeCalendarPage extends StatefulWidget {
  const HomeCalendarPage({super.key});

  @override
  State<HomeCalendarPage> createState() => _HomeCalendarPageState();
}

class _HomeCalendarPageState extends State<HomeCalendarPage> {
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  final GlobalKey _screenshotKey = GlobalKey();
  
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  
  List<PDVModel> _todayPDVs = [];
  List<PDVModel> _allPDVs = [];
  bool _isLoading = true;
  
  // Simuler un routing hebdomadaire
  final Map<int, List<String>> _weeklyRouting = {
    1: ['TR_FICT_001', 'TR_FICT_002', 'TR_FICT_003'], // Lundi
    2: ['TR_FICT_004', 'TR_FICT_005'], // Mardi
    3: ['TR_FICT_006', 'TR_FICT_007', 'TR_FICT_008'], // Mercredi
    4: ['TR_FICT_009', 'TR_FICT_010'], // Jeudi
    5: ['TR_FICT_001', 'TR_FICT_004', 'TR_FICT_007'], // Vendredi
    6: ['TR_FICT_002', 'TR_FICT_005'], // Samedi
    7: [], // Dimanche - repos
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pdvs = await _syncService.getPDVsOffline();
      setState(() {
        _allPDVs = pdvs;
        _updateTodayPDVs();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement données: $e')),
        );
      }
    }
  }

  void _updateTodayPDVs() {
    final dayOfWeek = _selectedDay.weekday;
    final todayPDVIds = _weeklyRouting[dayOfWeek] ?? [];
    
    _todayPDVs = _allPDVs.where((pdv) => todayPDVIds.contains(pdv.pdvId)).toList();
  }

  List<String> _getEventsForDay(DateTime day) {
    final dayOfWeek = day.weekday;
    final pdvIds = _weeklyRouting[dayOfWeek] ?? [];
    return pdvIds.map((id) {
      final pdv = _allPDVs.firstWhere((p) => p.pdvId == id, orElse: () => _allPDVs.first);
      return pdv.nomPdv;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _screenshotKey,
      child: Scaffold(
        body: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header avec informations utilisateur
                    _buildUserHeader(),
                    
                    // Résumé du jour sélectionné
                    _buildDaySummary(),
                    
                    // Liste des PDVs à visiter aujourd'hui (en haut)
                    _buildTodayPDVList(),
                    
                    // Calendrier (en bas)
                    _buildCalendar(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE53E3E),
            Color(0xFFD32F2F),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${_authService.userName?.split(' ').first ?? 'Merchandiser'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_authService.userZone} - ${_authService.userSecteurs?.join(', ') ?? ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Statut de synchronisation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_done,
                        size: 16,
                        color: Colors.green.shade200,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'En ligne',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade200,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Statistiques rapides
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'PDVs assignés',
                    '${_allPDVs.length}',
                    Icons.store,
                    Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Visites aujourd\'hui',
                    '${_todayPDVs.length}',
                    Icons.assignment_turned_in,
                    Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Cette semaine',
                    '${_weeklyRouting.values.expand((list) => list).length}',
                    Icons.calendar_month,
                    Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header du calendrier
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _getMonthYearText(_focusedDay),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Grille du calendrier simplifiée
            _buildSimpleCalendarGrid(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSimpleCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday - 1; // 0 = Lundi
    
    return Column(
      children: [
        // En-têtes des jours
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
              .map((day) => Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ))
              .toList(),
        ),
        
        const SizedBox(height: 8),
        
        // Grille des jours
        ...List.generate(6, (weekIndex) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
              
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(width: 32, height: 32);
              }
              
              final dayDate = DateTime(_focusedDay.year, _focusedDay.month, dayNumber);
              final isSelected = isSameDay(dayDate, _selectedDay);
              final isToday = isSameDay(dayDate, DateTime.now());
              final hasEvents = _getEventsForDay(dayDate).isNotEmpty;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = dayDate;
                    _updateTodayPDVs();
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE53E3E)
                        : isToday
                            ? const Color(0xFFE53E3E).withOpacity(0.5)
                            : hasEvents
                                ? Colors.orange.withOpacity(0.3)
                                : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: isSelected || isToday
                          ? Colors.white
                          : hasEvents
                              ? Colors.orange.shade700
                              : Colors.black87,
                      fontWeight: isSelected || isToday || hasEvents
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
  
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDaySummary() {
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final dayName = _getDayName(_selectedDay.weekday);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFE53E3E).withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? const Color(0xFFE53E3E).withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isToday ? Icons.today : Icons.calendar_today,
            color: isToday ? const Color(0xFFE53E3E) : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Aujourd\'hui - $dayName' : '$dayName ${_selectedDay.day}/${_selectedDay.month}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isToday ? const Color(0xFFE53E3E) : Colors.black87,
                  ),
                ),
                Text(
                  '${_todayPDVs.length} PDV${_todayPDVs.length > 1 ? 's' : ''} à visiter',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (_todayPDVs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_todayPDVs.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodayPDVList() {
    if (_todayPDVs.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.free_breakfast,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'Aucune visite planifiée',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isSameDay(_selectedDay, DateTime.now())
                    ? 'Profitez de votre journée libre !'
                    : 'Jour libre - pas de visites prévues',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Planning du jour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // TODO: Optimiser le routing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Optimisation du routing...')),
                  );
                },
                icon: const Icon(Icons.route, size: 16),
                label: const Text('Optimiser'),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _todayPDVs.length,
          itemBuilder: (context, index) {
            final pdv = _todayPDVs[index];
            return _buildPDVCard(pdv, index + 1);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPDVCard(PDVModel pdv, int order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _startVisit(pdv),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Numéro d'ordre
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '$order',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Informations PDV
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pdv.nomPdv,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pdv.adressage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.store, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          pdv.categoriePdv,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${(pdv.latitude * 100).round()}m',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Bouton d'action
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _startVisit(pdv),
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Color(0xFFE53E3E),
                  ),
                  tooltip: 'Commencer la visite',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    return days[weekday - 1];
  }
  
  String _getMonthYearText(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _startVisit(PDVModel pdv) {
    // Aller directement à la fiche de visite avec le PDV présélectionné
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisitFormPage(selectedPDV: pdv),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
