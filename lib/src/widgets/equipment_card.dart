// lib/src/widgets/equipment_card.dart

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/equipment_model.dart';

/// Card de equipamento para exibição em listas
/// 
/// Exibe as principais informações do equipamento de forma
/// compacta e visualmente atraente
class EquipmentCard extends StatelessWidget {
  final EquipmentModel equipment;
  final VoidCallback? onTap;
  final bool showDetails;
  
  const EquipmentCard({
    Key? key,
    required this.equipment,
    this.onTap,
    this.showDetails = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com número de série e status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          equipment.serialNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          equipment.model,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              
              if (showDetails) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                
                // Detalhes adicionais
                _buildDetailRow(
                  Icons.business,
                  'Cliente',
                  equipment.client ?? 'Não informado',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.timer,
                  'Total de Horas',
                  '${equipment.totalHours.toStringAsFixed(1)} horas',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.build,
                  'Próxima Manutenção',
                  equipment.nextMaintenance != null
                      ? _formatDate(equipment.nextMaintenance!)
                      : 'Não agendada',
                ),
                
                if (equipment.location != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.location_on,
                    'Localização',
                    equipment.location!.address ?? 'GPS: ${equipment.location!.latitude}, ${equipment.location!.longitude}',
                  ),
                ],
              ],
              
              // Alertas e operações
              if (!showDetails) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (equipment.alerts > 0)
                      _buildInfoChip(
                        Icons.warning,
                        '${equipment.alerts} alertas',
                        AppColors.error,
                      ),
                    if (equipment.alerts > 0) const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.functions,
                      '${equipment.operations} operações',
                      AppColors.info,
                    ),
                    const Spacer(),
                    if (equipment.isOffline)
                      Icon(
                        Icons.cloud_off,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip() {
    final color = AppColors.getEquipmentStatusColor(equipment.status.name);
    final icon = _getStatusIcon();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            equipment.statusDescription,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  IconData _getStatusIcon() {
    switch (equipment.status) {
      case EquipmentStatus.active:
        return Icons.check_circle;
      case EquipmentStatus.maintenance:
        return Icons.build_circle;
      case EquipmentStatus.inactive:
        return Icons.cancel;
      case EquipmentStatus.alert:
        return Icons.error;
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}