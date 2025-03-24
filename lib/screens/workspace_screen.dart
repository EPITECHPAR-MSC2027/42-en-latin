import 'package:fluter/providers/workspace_provider.dart';
import 'package:fluter/screens/boards_screen.dart';
import 'package:fluter/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  // Variables d'état pour gérer le chargement et les erreurs
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialisation des workspaces dès que l'écran est affiché
    _initializeWorkspaces();
  }

  // Fonction pour initialiser les workspaces
  void _initializeWorkspaces() {
    // Utilisation de Future.microtask pour exécuter la tâche immédiatement
    Future.microtask(() async {
      await _loadWorkspaces();
    });
  }

  // Fonction pour charger les workspaces via le provider
  Future<void> _loadWorkspaces() async {
    try {
      // Récupérer les workspaces via le provider
      await Provider.of<WorkspaceProvider>(context, listen: false).fetchWorkspaces();
    } catch (e) {
      // En cas d'erreur, afficher le message d'erreur
      setState(() => _errorMessage = e.toString());
    } finally {
      // Une fois le chargement terminé, mettre à jour l'état de chargement
      setState(() => _isLoading = false);
    }
  }

  // Afficher un dialogue pour ajouter un nouveau workspace
  Future<void> _addWorkspaceDialog(BuildContext context, WorkspaceProvider provider) async {
    // Variables pour stocker les informations du nouveau workspace
    String name = '';
    String displayName = '';
    String desc = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Créer un Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
                decoration: const InputDecoration(labelText: 'Nom'),
                onChanged: (String val) => name = val),
            TextField(
                decoration: const InputDecoration(labelText: 'Nom affiché'),
                onChanged: (String val) => displayName = val),
            TextField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (String val) => desc = val),
          ],
        ),
        actions: <Widget>[
          // Bouton pour annuler l'ajout
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          // Bouton pour créer un workspace
          TextButton(
            onPressed: () async {
              // Ajouter le nouveau workspace
              await provider.addWorkspace(name, displayName, desc);
              Navigator.pop(context);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  // Afficher un dialogue pour modifier un workspace existant
  Future<void> _editWorkspaceDialog(BuildContext context, workspace, WorkspaceProvider provider) async {
    // Variables pour stocker les nouvelles valeurs
    String newDisplayName = workspace.displayName;
    String newDesc = workspace.desc ?? '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Modifier Workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: TextEditingController(text: newDisplayName),
              decoration: const InputDecoration(labelText: 'Nom affiché'),
              onChanged: (String val) => newDisplayName = val,
            ),
            TextField(
              controller: TextEditingController(text: newDesc),
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (String val) => newDesc = val,
            ),
          ],
        ),
        actions: <Widget>[
          // Bouton pour annuler les modifications
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          // Bouton pour enregistrer les modifications
          TextButton(
            onPressed: () async {
              // Sauvegarder les modifications du workspace
              await provider.editWorkspace(workspace.id, newDisplayName, newDesc);
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // Afficher un dialogue pour supprimer un workspace
  Future<void> _deleteWorkspaceDialog(BuildContext context, workspace, WorkspaceProvider provider) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Supprimer Workspace'),
        content: Text('Êtes-vous sûr de vouloir supprimer le workspace "${workspace.displayName}" ?'),
        actions: <Widget>[
          // Bouton pour annuler la suppression
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          // Bouton pour confirmer la suppression
          TextButton(
            onPressed: () async {
              // Supprimer le workspace
              await provider.removeWorkspace(workspace.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEDE3),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // SingleChildScrollView pour permettre le défilement du contenu
          SingleChildScrollView(
            child: Column(
              children: [
                // AppBar personnalisée
                AppBar(
                  backgroundColor: const Color(0xFFC0CDA9),
                  centerTitle: true,
                  elevation: 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Vos WorkSpaces',
                        style: GoogleFonts.itim(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF889596),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                // Afficher un indicateur de chargement si _isLoading est vrai
                if (_isLoading) const Center(child: CircularProgressIndicator()) 
                // Si une erreur se produit, afficher le message d'erreur
                else _errorMessage != null
                        ? Center(child: Text('Erreur: $_errorMessage'))
                        : Consumer<WorkspaceProvider>(
                            builder: (context, provider, child) {
                              final workspaces = provider.workspaces;
                              if (workspaces.isEmpty) {
                                return const Center(child: Text('Aucun workspace trouvé.'));
                              }
                              // Affichage de la liste des workspaces
                              return ListView.builder(
                                shrinkWrap: true,  // Empêche la ListView de se développer à l'extérieur
                                padding: const EdgeInsets.all(16),
                                itemCount: workspaces.length,
                                itemBuilder: (context, index) {
                                  final workspace = workspaces[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      title: Text(
                                        workspace.displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(workspace.desc ?? 'Aucune description'),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (String value) async {
                                          if (value == 'edit') {
                                            await _editWorkspaceDialog(context, workspace, provider);
                                          } else if (value == 'delete') {
                                            await _deleteWorkspaceDialog(context, workspace, provider);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return [
                                            const PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Text('Modifier'),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text('Supprimer'),
                                            ),
                                          ];
                                        },
                                      ),
                                      // Navigation vers l'écran des boards du workspace
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BoardsScreen(
                                              workspaceId: workspace.id,
                                              workspaceName: workspace.displayName,
                                            ),
                                          ),
                                        );
                                        // Recharger les workspaces après la navigation
                                        _initializeWorkspaces();
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ],
            ),
          ),
          
          // Image en arrière-plan qui reste fixe pendant le défilement
          Positioned(
            left: -40,
            top: 3,
            child: SafeArea(
              child: Image.asset(
                'documentation/pic.png',
                height: 130,
                fit: BoxFit.contain,
              ),
            ),
          ),
          
        ],
      ),
      
      // Bouton flottant pour ajouter un nouveau workspace
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20), 
        child: FloatingActionButton(
          onPressed: () async {
            await _addWorkspaceDialog(context, Provider.of<WorkspaceProvider>(context, listen: false));
            _initializeWorkspaces(); // Recharger la liste après création
          },
          backgroundColor: const Color(0xFFC0CDA9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.settings, color: Color(0xFFD97C83)),
        ),
      ),
      // Navigation vers la barre de navigation inférieure
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
