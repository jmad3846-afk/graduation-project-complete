// ignore_for_file: deprecated_member_use, prefer_is_empty

import 'package:flutter/material.dart';

class AmbulanceDistributionScreen extends StatefulWidget {
  const AmbulanceDistributionScreen({super.key});

  @override
  State<AmbulanceDistributionScreen> createState() =>
      _AmbulanceDistributionScreenState();
}

class _AmbulanceDistributionScreenState
    extends State<AmbulanceDistributionScreen> {
  final Map<String, List<List<TextEditingController>>> _teamControllers = {};

  final List<_CenterDistributionData> _centers = [
    _CenterDistributionData(
      centerName: 'AMBULANCE CENTER 100',
      statusLabel: 'ACTIVE',
      statusColor: const Color(0xFF4CAF50),
      statusBackground: const Color(0xFFE8F5E9),
      teamCount: 3,
      teams: const [
        ['Khalid Al-Otaibi', 'Saeed Al-Zahrani', 'Mohammed Al-Shamri'],
        ['Khalid Al-Otaibi', 'Saeed Al-Zahrani', 'Mohammed Al-Shamri'],
        ['Khalid Al-Otaibi', 'Saeed Al-Zahrani', 'Mohammed Al-Shamri'],
      ],
      highlightedNames: {'Anas Al-Ghamdi', 'Sara Al-Salem'},
    ),
    _CenterDistributionData(
      centerName: 'AMBULANCE CENTER 110',
      statusLabel: 'ACTIVE',
      statusColor: const Color(0xFF4CAF50),
      statusBackground: const Color(0xFFE8F5E9),
      teamCount: 2,
      teams: const [
        ['Anas Al-Ghamdi', 'Sara Al-Salem', 'Yozoor Laugr'],
        ['Anas Al-Ghamdi', 'Sara Al-Salem', ''],
      ],
      highlightedNames: {'Anas Al-Ghamdi', 'Sara Al-Salem'},
    ),
    _CenterDistributionData(
      centerName: 'AMBULANCE CENTER 140',
      statusLabel: 'UNDER REVIEW',
      statusColor: const Color(0xFFF9A825),
      statusBackground: const Color(0xFFFFF8E1),
      teamCount: 3,
      teams: const [
        ['Khalid Al-Otaibi', 'Saeed Al-Zahrani', 'ADD REPLACEMENT'],
        ['Khalid Al-Otaibi', 'Sara Al-Salem', 'ADD REPLACEMENT'],
        ['ADD REPLACEMENT', 'ADD REPLACEMENT', 'ADD REPLACEMENT'],
      ],
      highlightedNames: {'Sara Al-Salem'},
    ),
    _CenterDistributionData(
      centerName: 'AMBULANCE CENTER 115',
      statusLabel: 'COMPLETED',
      statusColor: const Color(0xFF43A047),
      statusBackground: const Color(0xFFE8F5E9),
      teamCount: 2,
      teams: const [
        ['Clatell shlò', 'Sireyalt snem', 'Gyamh saona'],
        ['Anas Al-Ghamdi', 'Sara Al-Salem', 'Yara Al-Dossari'],
      ],
      highlightedNames: {'Anas Al-Ghamdi', 'Sara Al-Salem'},
    ),
  ];

  @override
  void initState() {
    super.initState();
    for (final center in _centers) {
      _teamControllers[center.centerName] = center.teams
          .map(
            (team) => team
                .map((member) => TextEditingController(text: member))
                .toList(),
          )
          .toList();
    }
  }

  @override
  void dispose() {
    for (final centerControllers in _teamControllers.values) {
      for (final team in centerControllers) {
        for (final controller in team) {
          controller.dispose();
        }
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 1000;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        GridView.builder(
                          itemCount: _centers.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 2 : 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: isWide ? 1.38 : 1.1,
                          ),
                          itemBuilder: (context, index) {
                            final center = _centers[index];
                            return _buildCenterCard(center);
                          },
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Distribution has been sent to the remote center screens.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                'SEND DISTRIBUTION TO CENTERS AUTOMATICALLY',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE1E6EF)),
        ),
      ),
      child: Row(
        children: [
          Text(
            'MONDAY, MARCH 23, 2026 - NIGHT SHIFT',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const Spacer(),
          Text(
            'AMBULANCE CREW SHIFT MANAGEMENT SYSTEM',
            textAlign: TextAlign.right,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterCard(_CenterDistributionData center) {
    final teams = _teamControllers[center.centerName]!;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildStatusChip(center),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      center.centerName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teams ${center.teamCount}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: List.generate(teams.length, (teamIndex) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: teamIndex == teams.length - 1 ? 0 : 10,
                      ),
                      child: _buildTeamPanel(
                        center: center,
                        teamIndex: teamIndex,
                        memberControllers: teams[teamIndex],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(_CenterDistributionData center) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: center.statusBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        center.statusLabel,
        style: TextStyle(
          color: center.statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildTeamPanel({
    required _CenterDistributionData center,
    required int teamIndex,
    required List<TextEditingController> memberControllers,
  }) {
    Color panelColor = const Color(0xFFEFF3F8);

    if (center.centerName == 'AMBULANCE CENTER 110' && teamIndex == 0) {
      panelColor = const Color(0xFFE8F5E9);
    } else if (center.centerName == 'AMBULANCE CENTER 110' && teamIndex == 1) {
      panelColor = const Color(0xFFFFEBEE);
    } else if (center.centerName == 'AMBULANCE CENTER 115') {
      panelColor = const Color(0xFFE8F5E9);
    } else if (center.centerName == 'AMBULANCE CENTER 100') {
      panelColor = const Color(0xFFE8F5E9);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Text(
            'Team ${memberControllers.length > 0 ? memberControllers.length == 3 ? (teamIndex == 0 ? 3 : teamIndex == 1 ? 2 : 1) : teamIndex + 1 : teamIndex + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(memberControllers.length, (memberIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildEditableMemberField(
                controller: memberControllers[memberIndex],
                highlightedNames: center.highlightedNames,
                isReplacementPlaceholder: memberControllers[memberIndex]
                        .text
                        .trim()
                        .toUpperCase() ==
                    'ADD REPLACEMENT',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEditableMemberField({
    required TextEditingController controller,
    required Set<String> highlightedNames,
    required bool isReplacementPlaceholder,
  }) {
    final isHighlighted = highlightedNames.contains(controller.text.trim());

    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 16,
        fontWeight: isHighlighted || isReplacementPlaceholder
            ? FontWeight.w600
            : FontWeight.w500,
        color: isReplacementPlaceholder
            ? Colors.black87
            : isHighlighted
                ? const Color(0xFF263238)
                : Colors.black87,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: isReplacementPlaceholder ? 'ADD REPLACEMENT' : null,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
        filled: true,
        fillColor: isHighlighted
            ? const Color(0xFFF8FAFC)
            : Colors.white.withOpacity(0.92),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isReplacementPlaceholder
                ? Colors.grey.shade500
                : Colors.grey.shade400,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blueGrey,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _CenterDistributionData {
  final String centerName;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackground;
  final int teamCount;
  final List<List<String>> teams;
  final Set<String> highlightedNames;

  const _CenterDistributionData({
    required this.centerName,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackground,
    required this.teamCount,
    required this.teams,
    this.highlightedNames = const {},
  });
}
