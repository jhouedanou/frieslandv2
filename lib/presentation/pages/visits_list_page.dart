import 'package:flutter/material.dart';
import '../../data/models/visite_model.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/auth_service.dart';
import 'visit_creation/pdv_selection_page.dart';
import 'map_page.dart';
import 'auth/login_page.dart';

// Écran d'accueil de l'app de terrain selon CLAUDE.md
// Structure: Liste vide avec bouton "+" (nouvelle visite)
class VisitesListPage extends StatefulWidget {
  final bool showAppBar;
  
  const VisitesListPage({super.key, this.showAppBar = true});

  @override
  State<VisitesListPage> createState() => _VisitesListPageState();
}

class _VisitesListPageState extends State<VisitesListPage> {
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  List<VisiteModel> _visites = [];
  bool _isLoading = true;
  String _syncStatus = 'Non connecté';

  @override
  void initState() {
    super.initState();
    _loadVisites();
    _setupSyncListeners();
  }

  Future<void> _loadVisites() async {
    try {
      final visites = await _syncService.getVisitesOffline();
      setState(() {
        _visites = visites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement: $e')),
        );
      }
    }
  }

  void _setupSyncListeners() {
    _syncService.syncStatus.listen((isConnected) {
      if (mounted) {
        setState(() {
          _syncStatus = isConnected ? 'Connecté' : 'Hors ligne';
        });
      }
    });

    _syncService.syncProgress.listen((progress) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(progress), duration: const Duration(seconds: 2)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              width: 32,
            ),
            const SizedBox(width: 12),
            const Text('Friesland Visites'),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        actions: [
          // Bouton carte OpenStreetMap
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapPage()),
              );
            },
            tooltip: 'Carte Treichville',
          ),
          // Status de synchronisation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _syncService.isOnline 
                        ? Icons.cloud_done 
                        : Icons.cloud_off,
                    size: 18,
                    color: _syncService.isOnline 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _syncStatus,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          // Menu utilisateur
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Menu utilisateur',
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _showUserProfile();
                  break;
                case 'sync':
                  if (_syncService.isOnline) _manualSync();
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 18),
                    const SizedBox(width: 8),
                    Text(_authService.userName ?? 'Utilisateur'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'sync',
                enabled: _syncService.isOnline,
                child: const Row(
                  children: [
                    Icon(Icons.sync, size: 18),
                    SizedBox(width: 8),
                    Text('Synchroniser'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadVisites,
              child: _visites.isEmpty 
                  ? _buildEmptyState()
                  : _buildVisitesList(),
            ),
      // Bouton "+" pour nouvelle visite selon CLAUDE.md
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewVisit,
        backgroundColor: const Color(0xFFE53E3E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune visite enregistrée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur + pour créer votre première visite',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewVisit,
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle Visite'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visites.length,
      itemBuilder: (context, index) {
        final visite = _visites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getSyncStatusColor(visite.syncStatus),
              child: Icon(
                _getSyncStatusIcon(visite.syncStatus),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              'PDV: ${visite.pdvId}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Commercial: ${visite.commercial}'),
                Text(
                  'Date: ${visite.dateVisite.day}/${visite.dateVisite.month}/${visite.dateVisite.year}',
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildProductBadge('EVAP', visite.produits.evap.present),
                    _buildProductBadge('IMP', visite.produits.imp.present),
                    _buildProductBadge('SCM', visite.produits.scm.present),
                    _buildProductBadge('UHT', visite.produits.uht.present),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              visite.geofenceValidated 
                  ? Icons.location_on 
                  : Icons.location_off,
              color: visite.geofenceValidated 
                  ? Colors.green 
                  : Colors.red,
            ),
            onTap: () => _viewVisiteDetails(visite),
          ),
        );
      },
    );
  }

  Widget _buildProductBadge(String name, bool present) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: present ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getSyncStatusColor(String status) {
    switch (status) {
      case 'synced': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getSyncStatusIcon(String status) {
    switch (status) {
      case 'synced': return Icons.cloud_done;
      case 'pending': return Icons.cloud_upload;
      case 'failed': return Icons.cloud_off;
      default: return Icons.help;
    }
  }

  // Navigation vers création de visite selon CLAUDE.md
  void _createNewVisit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PDVSelectionPage(),
      ),
    ).then((_) => _loadVisites()); // Refresh après création
  }

  void _viewVisiteDetails(VisiteModel visite) {
    // TODO: Implémenter vue détail visite
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Détails visite ${visite.visiteId}')),
    );
  }

  Future<void> _manualSync() async {
    try {
      await _syncService.forcSync();
      await _loadVisites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Synchronisation réussie !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur sync: $e')),
        );
      }
    }
  }

  void _showUserProfile() {
    final userStats = _authService.getUserStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFFE53E3E)),
            const SizedBox(width: 8),
            const Text('Profil Utilisateur'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileItem('Nom', _authService.userName ?? 'Non défini'),
            _buildProfileItem('Email', _authService.currentUser?['email'] ?? 'Non défini'),
            _buildProfileItem('Rôle', _authService.userRole ?? 'Non défini'),
            _buildProfileItem('Zone', _authService.userZone ?? 'Non définie'),
            _buildProfileItem('Secteurs', _authService.userSecteurs?.join(', ') ?? 'Non définis'),
            const Divider(),
            _buildProfileItem('Total visites', '${userStats['total_visits']}'),
            _buildProfileItem('En attente sync', '${userStats['pending_sync']}'),
            if (userStats['last_sync'] != null)
              _buildProfileItem(
                'Dernière sync', 
                '${(userStats['last_sync'] as DateTime).hour}h${(userStats['last_sync'] as DateTime).minute.toString().padLeft(2, '0')}'
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }
}