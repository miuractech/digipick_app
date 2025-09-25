import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DeviceSelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> devices;
  final List<String> selectedDeviceIds;
  final ValueChanged<List<String>> onSelectionChanged;
  final String accessType; // 'all', 'specific', 'none'
  final ValueChanged<String> onAccessTypeChanged;

  const DeviceSelectionWidget({
    super.key,
    required this.devices,
    required this.selectedDeviceIds,
    required this.onSelectionChanged,
    required this.accessType,
    required this.onAccessTypeChanged,
  });

  @override
  State<DeviceSelectionWidget> createState() => _DeviceSelectionWidgetState();
}

class _DeviceSelectionWidgetState extends State<DeviceSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDevices = [];
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _filteredDevices = widget.devices;
    _searchController.addListener(_filterDevices);
    _updateSelectAllState();
  }

  @override
  void didUpdateWidget(DeviceSelectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.devices != widget.devices) {
      _filteredDevices = widget.devices;
      _filterDevices();
    }
    if (oldWidget.selectedDeviceIds != widget.selectedDeviceIds) {
      _updateSelectAllState();
    }
  }

  void _filterDevices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDevices = widget.devices;
      } else {
        _filteredDevices = widget.devices.where((device) {
          final deviceName = (device['device_name'] ?? '').toLowerCase();
          final make = (device['make'] ?? '').toLowerCase();
          final model = (device['model'] ?? '').toLowerCase();
          final serialNumber = (device['serial_number'] ?? '').toLowerCase();
          
          return deviceName.contains(query) ||
                 make.contains(query) ||
                 model.contains(query) ||
                 serialNumber.contains(query);
        }).toList();
      }
      _updateSelectAllState();
    });
  }

  void _updateSelectAllState() {
    if (_filteredDevices.isEmpty) {
      _selectAll = false;
    } else {
      _selectAll = _filteredDevices.every((device) => 
        widget.selectedDeviceIds.contains(device['id']));
    }
  }

  void _toggleSelectAll() {
    List<String> newSelection = List.from(widget.selectedDeviceIds);
    
    if (_selectAll) {
      // Deselect all filtered devices
      for (var device in _filteredDevices) {
        newSelection.remove(device['id']);
      }
    } else {
      // Select all filtered devices
      for (var device in _filteredDevices) {
        if (!newSelection.contains(device['id'])) {
          newSelection.add(device['id']);
        }
      }
    }
    
    widget.onSelectionChanged(newSelection);
  }

  void _toggleDevice(String deviceId) {
    List<String> newSelection = List.from(widget.selectedDeviceIds);
    
    if (newSelection.contains(deviceId)) {
      newSelection.remove(deviceId);
    } else {
      newSelection.add(deviceId);
    }
    
    widget.onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Access Type Selection
        const Text(
          'Device Access:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        
        // Access Type Radio Buttons
        Column(
          children: [
            RadioListTile<String>(
              title: const Text('No device access'),
              subtitle: const Text('User cannot access any devices'),
              value: 'none',
              groupValue: widget.accessType,
              onChanged: (value) => widget.onAccessTypeChanged(value!),
              contentPadding: EdgeInsets.zero,
            ),
            
            RadioListTile<String>(
              title: const Text('All devices'),
              subtitle: const Text('User can access all organization devices'),
              value: 'all',
              groupValue: widget.accessType,
              onChanged: (value) => widget.onAccessTypeChanged(value!),
              contentPadding: EdgeInsets.zero,
            ),
            
            RadioListTile<String>(
              title: const Text('Specific devices'),
              subtitle: Text(
                widget.accessType == 'specific' 
                  ? '${widget.selectedDeviceIds.length} device(s) selected'
                  : 'Choose specific devices for this user'
              ),
              value: 'specific',
              groupValue: widget.accessType,
              onChanged: (value) => widget.onAccessTypeChanged(value!),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        
        // Device Selection (when specific is selected)
        if (widget.accessType == 'specific') ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Search and Stats Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Devices',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.selectedDeviceIds.length}/${widget.devices.length} selected',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search devices by name, make, model, or serial...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primaryAccent),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Select All / Clear All Controls
          if (_filteredDevices.isNotEmpty) ...[
            Row(
              children: [
                TextButton.icon(
                  onPressed: _toggleSelectAll,
                  icon: Icon(
                    _selectAll ? Icons.deselect : Icons.select_all,
                    size: 18,
                  ),
                  label: Text(_selectAll ? 'Deselect All' : 'Select All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryAccent,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_filteredDevices.length} device(s) found',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Device List
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _filteredDevices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _filteredDevices.length,
                    itemBuilder: (context, index) {
                      final device = _filteredDevices[index];
                      return _buildDeviceListItem(device);
                    },
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    if (widget.devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices_other, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No devices available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add devices to your organization first',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No devices found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDeviceListItem(Map<String, dynamic> device) {
    final deviceId = device['id'];
    final isSelected = widget.selectedDeviceIds.contains(deviceId);
    final deviceName = device['device_name'] ?? 'Unknown Device';
    final make = device['make'] ?? '';
    final model = device['model'] ?? '';
    final serialNumber = device['serial_number'] ?? '';
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (selected) => _toggleDevice(deviceId),
        title: Text(
          deviceName,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (make.isNotEmpty || model.isNotEmpty)
              Text(
                '$make $model'.trim(),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            if (serialNumber.isNotEmpty)
              Text(
                'Serial: $serialNumber',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppColors.primaryAccent,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
